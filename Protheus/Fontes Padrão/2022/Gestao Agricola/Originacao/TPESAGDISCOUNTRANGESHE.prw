#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWdiscountRangesAdapter
	
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
	
	DATA oArrayJson			as ARRAY
	DATA oDiscountRanges	as ARRAY
	DATA oAnalysisDisc		as ARRAY
	DATA oAnalysis			as ARRAY
	
	DATA oModel		  		as OBJECT
	DATA oFieldsJson  		as OBJECT
	DATA oFieldsJsw   		as OBJECT
	DATA oEaiObjSnd   		as OBJECT
	DATA oEaiObjSn2   		as OBJECT
	DATA oEaiObjRec   		as OBJECT
	DATA oFieldsAnalysisHe  as OBJECT

	METHOD NEW()	
	METHOD GetdiscountRanges()
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
Method NEW() CLASS FWdiscountRangesAdapter
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
	self:oFieldsAnalysisHe  := JsonObject():New()	//FWEAIObj():NEW()//JsonObject():New()	
	
	self:oEaiObjSnd 		:= FWEAIObj():NEW()
	self:oEaiObjSn2 		:= JsonObject():New()
	self:oEaiObjRec 		:= Nil
	
	self:oArrayJson			:= {}
	self:oDiscountRanges	:= {}
	self:oAnalysisDisc		:= {}
	self:oAnalysis			:= {}
	
Return


/*/{Protheus.doc} GetNames
//Responsável por setar os atributos ao objeto JSON que será retornado na busca.
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@return oFieldsJson, Obejto json contendo os campos da tabela

@type function
/*/
Method GetNames() CLASS FWdiscountRangesAdapter
	Local oFieldsJson as OBJECT
	
	oFieldsJson := &('JsonObject():New()')
	
	//oFieldsJson['id']			:= '' 
	//oFieldsJson['cddiscountRanges']			:= 'NNI_CODIGO'
	//oFieldsJson['dediscountRanges']			:= 'NNI_DESCRI'
	
return {oFieldsJson}

/*/{Protheus.doc} GetdiscountRanges
//Responsável por trazer a busca das safras
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, Código único do conjunto
@type function
/*/
Method GetdiscountRanges(cCodId) CLASS FWdiscountRangesAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local lFields		as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nX			as NUMERIC
	Local nArray		as NUMERIC
	Local nDiscountRanges	as NUMERIC
	Local nAnalysisDisc	as NUMERIC
	Local nAnalysis		as NUMERIC
	Local nDiscProd		as NUMERIC
	Local nListDisRange as NUMERIC
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
	Local nAnalysisHe	as CHARACTER
	Local cRegistro		as CHARACTER
	
	aSelFields 	:= NIL
	nJ		 	:= 1
	nX			:= 1
	nArray 		:= 1
	nDiscountRanges	:= 1
	nAnalysis	:= 1
	nAnalysisDisc	:= 1
	nAnalysisHe := 1
	nDiscProd 	:= 1
	nListDisRange := 1
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
		self:oFieldsAnalysisHe:Activate()
		
		lNext := .T.
		aRetAlias := Self:CreateQuery(cCod)
		cAliasNNI := aRetAlias[1]
		//cAliasNNH := aRetAlias[2]
		
		Self:oEaiobjSnd:setBatch(1)
		
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
		if !(cAliasNNI->(EOF()))
			While !(cAliasNNI->(EOF()))
				nListDisRange := 1
		 		nDiscountRanges := 1
		 		nAnalysisDisc := 1
		 		nAnalysis := 1
			 	
			 	if SELECT('cAliasNNH') > 0
					cAliasNNH->(dbCloseArea())
					cAliasNNH 	:= GetNextAlias()
				endIf
				
				cQuery := " select * from " + RetSqlName("NNH") + " NNH "
				cQuery += " INNER JOIN " + RetSqlName("NNJ") + " NNJ ON NNH.NNH_CODIGO = NNJ.NNJ_CODDES "
				cQuery += " INNER JOIN " + RetSqlName("NNI") + " NNI ON NNJ.NNJ_CODTAB = NNI.NNI_CODIGO"
				cQuery += " INNER JOIN " + RetSqlName("NNK") + " NNK ON NNJ.NNJ_CODTAB = NNK.NNK_CODTAB AND NNJ.NNJ_CODDES = NNK.NNK_CODDES "
				cQuery += " WHERE NNH .D_E_L_E_T_ = ' ' "
				cQuery += " AND NNJ.D_E_L_E_T_ = ' ' "
				cQuery += " AND NNI.D_E_L_E_T_ = ' ' "
				cQuery += " AND NNK.D_E_L_E_T_ = ' ' "
				cQuery += " AND NNI.NNI_CODIGO = '" + cAliasNNI->NNI_CODIGO + "'"
				cQuery := ChangeQuery(cQuery)
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"cAliasNNH",.F.,.T.)
			 		
				AADD(self:oArrayJson,JsonObject():NEW())
				Self:oEaiObjSnd:setProp('id', cAliasNNI->NNI_CODIGO)
				Self:oEaiObjSnd:setProp('analysisHE', self:oArrayJson[nArray])
				Self:oEaiObjSnd:setProp('description', ALLTRIM(cAliasNNI->NNI_DESPRO))
				
				//Self:oEaiObjSnd:getpropvalue('analysisHE')[nx]:setprop('idAnalysis',	cAliasNNI->NNI_CODIGO)
				//Self:oEaiObjSnd:getpropvalue('analysisHE')[nx]:setprop('cdAnalysis',	cAliasNNI->NNI_CODIGO)
				//Self:oEaiObjSnd:getpropvalue('analysisHE')[nx]:setprop('deAnalysis',	cAliasNNI->NNI_DESCRI)
				
				self:oArrayJson[nArray]['idAnalysis'] := cAliasNNI->NNI_CODIGO
				self:oArrayJson[nArray]['cdAnalysis'] := cAliasNNI->NNI_CODIGO
				self:oArrayJson[nArray]['deAnalysis'] := cAliasNNI->NNI_DESCRI
				
				nx:=1
				cAliasNNH->(DBGOTOP())
				Self:oArrayJson[nArray]['lstAnalysisDe'] := {}				
				while !(cAliasNNH->(EOF()))									
					Aadd(self:oArrayJson[nArray]['lstAnalysisDe'], JsonObject():New())
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['idAnlDe'] 		:=		cAliasNNI->(NNI_CODIGO)+cAliasNNH->(NNH_CODIGO)
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['idAnalysesHe'] 	:=		cAliasNNI->(NNI_CODIGO)
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['cdAnlDe'] 		:=		cAliasNNH->(NNH_CODIGO)
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['deAnlDe'] 		:=		ALLTRIM(cAliasNNH->(NNH_DESCRI))
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['daAnlDe'] 		:=		SUBSTR(ALLTRIM(cAliasNNH->(NNH_DESCRI)),1,10)
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['qtSize'] 			:=		'8'
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['qtDecimals'] 		:=		'2'
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['noInput']			:=		nx
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['noSeqTyping']		:=		nx
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['noSeqPrint']		:=		nx
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['deductNetWei']	:=		'S'
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['noSeqdeduct']		:=		nx
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['required']		:=		'N'
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['type']			:=		'NUMBER'
			 		Self:oArrayJson[nArray]['lstAnalysisDe'][nX]['roundType']		:=		'SEM_ARREDONDAMENTO'
					
			 		cAliasNNH->(DbSkip())
			 		nX++
				end
				
				Self:oEaiObjSnd:setProp('products', {ALLTRIM(cAliasNNI->NNI_CODPRO)})
				//cAliasNNI->(DBGOTOP())
				//while !(cAliasNNI->(EOF()))					 	
			 	Self:oEaiObjSnd:setProp('discountProducts', {})	 					 		
		 		Self:oEaiObjSnd:getpropvalue('discountProducts')[nDiscProd]:setprop('id',				ALLTRIM(cAliasNNI->NNI_CODIGO+cAliasNNI->NNI_CODPRO))
		 		Self:oEaiObjSnd:getpropvalue('discountProducts')[nDiscProd]:setprop('idProduct',		ALLTRIM(cAliasNNI->NNI_CODPRO))
		 		Self:oEaiObjSnd:getpropvalue('discountProducts')[nDiscProd]:setprop('idDiscountRange',	ALLTRIM(cAliasNNI->NNI_CODIGO))
		 		//cAliasNNI->(DbSkip())
				//endDo
				
				cRegistro := ''
				cAliasNNH->(DBGOTOP())
				while !(cAliasNNH->(EOF()))
					Self:oEaiObjSnd:setProp('listDiscountRangesDE', {})
					
					if cRegistro != cAliasNNH->NNK_CODDES .and. cAliasNNH->NNK_PERINI > 0
						Self:oEaiObjSnd:getpropvalue('listDiscountRangesDE')[nListDisRange]:setprop('id',		cAliasNNH->NNK_CODTAB+cAliasNNH->NNK_CODDES+cAliasNNH->NNK_SEQ+'0')
						Self:oEaiObjSnd:getpropvalue('listDiscountRangesDE')[nListDisRange]:setprop('value', cAliasNNH->NNK_PERINI - 0.01)
						Self:oEaiObjSnd:getpropvalue('listDiscountRangesDE')[nListDisRange]:setprop('discount',	0)
					else
						Self:oEaiObjSnd:getpropvalue('listDiscountRangesDE')[nListDisRange]:setprop('id',		cAliasNNH->NNK_CODTAB+cAliasNNH->NNK_CODDES+cAliasNNH->NNK_SEQ+'1')
						Self:oEaiObjSnd:getpropvalue('listDiscountRangesDE')[nListDisRange]:setprop('value',	cAliasNNH->NNK_PERFIM)
						Self:oEaiObjSnd:getpropvalue('listDiscountRangesDE')[nListDisRange]:setprop('discount',	cAliasNNH->NNK_PERDES)
					endif
					
					AADD(self:oDiscountRanges,JsonObject():NEW())
					AADD(self:oAnalysisDisc,JsonObject():NEW())
					AADD(self:oAnalysis,JsonObject():NEW())
					Self:oEaiObjSnd:getpropvalue('listDiscountRangesDE')[nListDisRange];
					:setProp('discountRangesHE', self:oDiscountRanges[nDiscountRanges])
					self:oDiscountRanges[nDiscountRanges]['id'] := cAliasNNI->NNI_CODIGO
					self:oDiscountRanges[nDiscountRanges]['listDiscountRangesDE'] := {}
					self:oDiscountRanges[nDiscountRanges]['description'] := ALLTRIM(cAliasNNI->NNI_DESCRI)
					
					Self:oDiscountRanges[nDiscountRanges]['analysisHE'] := self:oAnalysisDisc[nAnalysisDisc]				
					self:oAnalysisDisc[nAnalysisDisc]['idAnalysis'] := cAliasNNI->NNI_CODIGO
					self:oAnalysisDisc[nAnalysisDisc]['cdAnalysis'] := cAliasNNI->NNI_CODIGO
					self:oAnalysisDisc[nAnalysisDisc]['deAnalysis'] := ALLTRIM(cAliasNNI->NNI_DESCRI)
				
					Self:oEaiObjSnd:getpropvalue('listDiscountRangesDE')[nListDisRange];
					:setProp('analysisDE', self:oAnalysis[nAnalysis])
					
					Self:oAnalysis[nAnalysis]['idAnlDe'] 		:=		cAliasNNI->(NNI_CODIGO)+cAliasNNH->(NNH_CODIGO)
			 		Self:oAnalysis[nAnalysis]['idAnalysesHe'] 	:=		cAliasNNI->(NNI_CODIGO)
			 		Self:oAnalysis[nAnalysis]['cdAnlDe'] 		:=		cAliasNNH->(NNH_CODIGO)
			 		Self:oAnalysis[nAnalysis]['deAnlDe'] 		:=		ALLTRIM(cAliasNNH->(NNH_DESCRI))
			 		Self:oAnalysis[nAnalysis]['daAnlDe'] 		:=		SUBSTR(ALLTRIM(cAliasNNH->(NNH_DESCRI)),1,10)
			 		Self:oAnalysis[nAnalysis]['qtSize'] 		:=		'8'
			 		Self:oAnalysis[nAnalysis]['qtDecimals'] 	:=		'2'
			 		Self:oAnalysis[nAnalysis]['noInput']		:=		nAnalysis
			 		Self:oAnalysis[nAnalysis]['noSeqTyping']	:=		nAnalysis
			 		Self:oAnalysis[nAnalysis]['noSeqPrint']		:=		nAnalysis
			 		Self:oAnalysis[nAnalysis]['deductNetWei']	:=		'S'
			 		Self:oAnalysis[nAnalysis]['noSeqdeduct']	:=		nAnalysis
			 		Self:oAnalysis[nAnalysis]['required']		:=		'N'
			 		Self:oAnalysis[nAnalysis]['type']			:=		'NUMBER'
			 		Self:oAnalysis[nAnalysis]['roundType']		:=		'SEM_ARREDONDAMENTO'
			 		
			 		//Self:oEaiobjSnd:getpropvalue('listDiscountRangesDE')[nListDisRange]:nextItem()			 		
			 		if cRegistro == cAliasNNH->NNK_CODDES .or. cAliasNNH->NNK_PERINI == 0
			 			cRegistro := cAliasNNH->NNK_CODDES
			 			cAliasNNH->(DbSkip())
			 		else
			 			cRegistro := cAliasNNH->NNK_CODDES
			 		endif
			 		nListDisRange++
			 		nDiscountRanges++
			 		nAnalysisDisc++
			 		nAnalysis++
		 		enddo
				 		
				cAliasNNI->(DbSkip())
				
				nArray++
				if !(nCount >= (Self:oEaiObjRec:GetPageSize() * Self:oEaiObjRec:GetPage())) .AND. !(cAliasNNI->(EOF()))
					Self:oEaiobjSnd:nextItem()
				endif
			endDo
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
Method CreateQuery(cCod) CLASS FWdiscountRangesAdapter
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
		
		cQuery1 := "SELECT DISTINCT NNI.* "
		cQuery2 := " FROM " + RetSqlName("NNI") + " NNI "
		cQuery2 += " INNER JOIN " + RetSqlName("NNJ") + " NNJ ON NNI.NNI_CODIGO = NNJ.NNJ_CODTAB "
		cQuery2 += " WHERE NNI.D_E_L_E_T_ = ' ' "
		cQuery2 += " AND NNJ.D_E_L_E_T_ = ' ' "
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
Return {cAliasNNI}