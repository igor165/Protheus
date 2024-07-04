#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWanalysisAdapter
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA cfields			as CHARACTER
	DATA cError       		as CHARACTER
	DATA cInternalId		as CHARACTER
	DATA cMsgName     		as CHARACTER
	DATA cTipRet	  		as CHARACTER
	DATA cSelectedFields	as CHARACTER
	
	DATA oModel		  		as OBJECT
	DATA oFieldsJson  		as OBJECT
	DATA oFieldsJsw   		as OBJECT
	DATA oEaiObjSnd   		as OBJECT
	DATA oEaiObjSn2   		as OBJECT
	DATA oEaiObjRec   		as OBJECT

	METHOD NEW()	
	METHOD Getanalysis()
	METHOD GetNames()
	METHOD GetNmsW()
	
	METHOD CreateQuery()
	
EndClass


/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@type function

/*/
Method NEW() CLASS FWanalysisAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:cfields		   	:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'TPESAG'
	Self:cSelectedFields 	:= ''
	Self:cTipRet		 	:= '' //Tipo de retorno -> 1=Array;2=NãoArray 
	
	self:oFieldsJson  		:= self:GetNames()[1]
	
	self:oEaiObjSnd 		:= FWEAIObj():NEW()
	self:oEaiObjSn2 		:= JsonObject():New()
	self:oEaiObjRec 		:= Nil
	
Return


/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@return oFieldsJson, Obejto json contendo os campos da tabela

@type function
/*/
Method GetNames() CLASS FWanalysisAdapter
	Local oFieldsJson as OBJECT
	
	oFieldsJson := &('JsonObject():New()')
	
	oFieldsJson['idAnalysis']			:= 'NNI_CODIGO' 
	oFieldsJson['cdAnalysis']			:= 'NNI_CODIGO'
	oFieldsJson['deAnalysis']			:= 'NNI_DESCRI'
	
return {oFieldsJson}

/*/{Protheus.doc} Getanalysis
//Responsável por trazer a busca das safras
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, Código único do conjunto
@type function
/*/
Method Getanalysis(cCodId) CLASS FWanalysisAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local lFields		as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nX			as NUMERIC
	Local nLastRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasNNI 	as CHARACTER
	Local cAliasNNH 	as CHARACTER
	Local cCodId 	    as CHARACTER
	Local cCod	 	    as CHARACTER
	Local cQuery 	    as CHARACTER
	Local cField		as CHARACTER
	Local cValue		as CHARACTER
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
		
		cAliasNNI := 'NNI'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('code')
		Else
			cCod := cCodId
		EndIf
		
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		
		lNext := .T.
		aRetAlias := Self:CreateQuery(cCod)
		cAliasNNI := aRetAlias[1]
		cAliasNNH := aRetAlias[2]
		
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
			If !(cAliasNNI->(Eof()))					
				While !(cAliasNNI->(EOF()))
					nCount++
					
					If !(oPage:CanAddLine())
						nMaxRec := nCount
						cAliasNNI->(dbskip())
						LOOP
					endIf
					
					For nJ := 1 to Len(aSelFields)
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, cAliasNNI->&(Self:oFieldsJson[cField]))
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
					Next nJ			
					
					nx:=1
					cAliasNNH->(DBGOTOP())
					while !(cAliasNNH->(EOF()))					 	
					 	Self:oEaiObjSnd:setProp('lstAnalysisDe', {})	 					 		
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('idAnlDe',		cAliasNNI->(NNI_CODIGO)+cAliasNNH->(NNH_CODIGO))
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('idAnalysesHe',	cAliasNNI->(NNI_CODIGO))
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('cdAnlDe',		cAliasNNH->(NNH_CODIGO))
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('deAnlDe',		ALLTRIM(cAliasNNH->(NNH_DESCRI)))
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('daAnlDe',		SUBSTR(ALLTRIM(cAliasNNH->(NNH_DESCRI)),1,10))
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('qtSize',			'4')
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('qtDecimals',		'2')
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('noInput',		nx)
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('noSeqTyping',	nx)
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('noSeqPrint',		nx)
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('deductNetWei',	'S')
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('noSeqdeduct',	nx)
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('required',		'N')
				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('type',			'NUMBER')
 				 		Self:oEaiObjSnd:getpropvalue('lstAnalysisDe')[nX]:setprop('roundType',		'SEM_ARREDONDAMENTO') 
				 		cAliasNNH->(DbSkip())
				 		nX++
					endDo
					
					nLastRec := nCount
					cAliasNNI->(DbSkip())
					
					if !(nCount >= (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())) .AND. !(cAliasNNI->(EOF()))
						Self:oEaiobjSnd:nextItem()
					endif
				endDo
				
				if nCount > (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())
					Self:oEaiobjSnd:setHasNext(.T.)			
				EndIf
			endIf
		else		
			if !(cAliasNNI->(EOF()))
				for nJ := 1 to Len(aSelFields)
				
					if aSelFields[nJ] = 'code'
						Self:oEaiObjSn2['code'] := cAliasNNI->&(Self:oFieldsJson['code'])
					else
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, cAliasNNI->&(Self:oFieldsJson[cField]))
						
						if cValue != NIL
							IF VALTYPE(cValue) = "C"
								self:oEaiObjSn2[cField]	:= AllTrim(cValue)
							elseif VALTYPE(cValue) = "N"
								self:oEaiObjSn2[cField]	:= cValToChar(cValue)
							endIf
						else
							Self:cError := 'A propriedade do ' + cField + ' fields  não é valida.' + CRLF
							Self:lOk := .F.
							cAliasNNI->(DBCloseArea())
							Return()
						endIf
					endIf
				next nJ	
				
				nX := 1
				cAliasNNH->(DBGOTOP())
				self:oEaiObjSn2['lstAnalysisDe'] := {}
				while !(cAliasNNH->(EOF()))									
					Aadd(self:oEaiObjSn2['lstAnalysisDe'], JsonObject():New())
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['idAnlDe'] 		:=		cAliasNNI->(NNI_CODIGO)+cAliasNNH->(NNH_CODIGO)
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['idAnalysesHe'] 	:=		cAliasNNI->(NNI_CODIGO)
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['cdAnlDe'] 		:=		cAliasNNH->(NNH_CODIGO)
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['deAnlDe'] 		:=		ALLTRIM(cAliasNNH->(NNH_DESCRI))
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['daAnlDe'] 		:=		SUBSTR(ALLTRIM(cAliasNNH->(NNH_DESCRI)),1,10)
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['qtSize'] 			:=		'8'
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['qtDecimals'] 		:=		'2'
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['noInput']			:=		nx
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['noSeqTyping']		:=		nx
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['noSeqPrint']		:=		nx
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['deductNetWei']	:=		'S'
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['noSeqdeduct']		:=		nx
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['required']		:=		'N'
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['type']			:=		'NUMBER'
			 		Self:oEaiObjSn2['lstAnalysisDe'][nX]['roundType']		:=		'SEM_ARREDONDAMENTO'
					
			 		cAliasNNH->(DbSkip())
			 		nX++
				end
							
			else
				Self:cError := 'Não existe registro com este código.' + CRLF
				Self:lOk	:= .F.
			endIf	
		endIf		
		cAliasNNI->(DBCloseArea())
		cAliasNNH->(DBCloseArea())		
	endIf
Return lRet

/*/{Protheus.doc} CreateQuery
// Reponsável por montar a query de busca no banco de dados
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@return TPESAGSX3, tabela temporária com o resultado da consulta efetuada no BD.
@param cCod, characters, código do registro a ser consultado.
@type function
/*/
Method CreateQuery(cCod) CLASS FWanalysisAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasNNI    as CHARACTER
	Local cAliasNNH	   as CHARACTER	
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasNNI 	:= GetNextAlias()
	cAliasNNH 	:= GetNextAlias()
	cWhere 		:= ""
	cOrder		:= ""
	cValWhe		:= ""
	
	if SELECT(cAliasNNI) > 0
		cAliasNNI->(dbCloseArea())
		cAliasNNI 	:= GetNextAlias()
	endIf
	
	//Pega os atributos que foram passado para o filtro
	oJsonFilter  := Self:oEaiObjRec:getFilter()
	
	if oJsonFilter != Nil
		aTemp := oJsonFilter:getProperties()
		
		for nX := 1 to len(aTemp)
			if aTemp[nX] == 'EXPAND'
				ADEL(aTemp,nX)
			endif
		next nX
		
		for nX := 1 to len(aTemp)
			cValWhe := aTemp[nX]
			if !Empty(aTemp[nX])
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
					Self:cError += 'A propriedade ' + aTemp[nX] + ' não é válida para Ordenação' + CRLF
					lRet := .F.
				EndIf
			Else
				if !Empty(Self:oFieldsJson[cValOrd])
					cOrder += Self:oFieldsJson[aTemp[nX]]
				Else
					Self:cError += 'A propriedade ' + aTemp[nX] + ' não é válida para Ordenação' + CRLF
					lRet := .F.
				EndIf
			EndIf
		next nX
	else
		If !Empty(cCod)
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := "and NNI_CODIGO = '" + aRet[1] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('code')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('code'), "|" )
			cWhere := "and NNI_CODIGO = '" + aRet[1] + "' "
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		cQuery1 := "SELECT * "
		cQuery2 := " FROM " + RetSqlName("NNI") + " NNI "
		cQuery2 += " WHERE D_E_L_E_T_ = ' ' "
		cQuery2 += " " + cWhere + " "
		
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder
		else
			cQuery2 += " ORDER BY NNI_FILIAL, NNI_CODIGO "
		endif
		
		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"cAliasNNI",.F.,.T.)
		
		if !EMPTY(cValWhe)
			if GETDATASQL("SELECT  COUNT(*)" + cQuery2) > 1
				self:cTipRet = '1'
			else
				self:cTipRet = '2'
			endIf
		endIf
		
		If !Empty(cCod)
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := "and NNI_CODIGO = '" + aRet[1]
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('code')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('code'), "|" )
			cWhere := "and NNI_CODIGO = '" + aRet[1]
		endIf
		
	else
		Self:lOk := .F.
	EndIf
	
	if SELECT(cAliasNNH) > 0
		cAliasNNH->(dbCloseArea())
		cAliasNNH 	:= GetNextAlias()
	endIf
	
	cQuery := " select * from " + RetSqlName("NNH")
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"cAliasNNH",.F.,.T.)
Return {cAliasNNI, cAliasNNH}