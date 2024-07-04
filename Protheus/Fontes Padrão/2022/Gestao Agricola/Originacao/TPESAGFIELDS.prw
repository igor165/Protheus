#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWfieldsAdapter
	
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
	METHOD Getfields()
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
Method NEW() CLASS FWfieldsAdapter
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
Method GetNames() CLASS FWfieldsAdapter
	Local oFieldsJson as OBJECT
	
	oFieldsJson := &('JsonObject():New()')
	
	oFieldsJson['id']				:= 'X3_CAMPO'
	oFieldsJson['description']		:= 'X3_DESCRIC'
	
return {oFieldsJson}

/*/{Protheus.doc} Getfields
//Responsável por trazer a busca das safras
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, Código único do conjunto
@type function
/*/
Method Getfields(cCodId) CLASS FWfieldsAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local lFields		as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nX			as NUMERIC
	Local nLastRec		as NUMERIC
	Local nMaxRec		as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasSX3 	as CHARACTER
	Local cAliasPK		as CHARACTER
	Local cCodId 	    as CHARACTER
	Local cCod	 	    as CHARACTER
	Local cQuery 	    as CHARACTER
	Local cField		as CHARACTER
	Local cValue		as CHARACTER
	Local aSelFields	as ARRAY
	Local oPage      	as OBJECT
	Local oTempJson    	as OBJECT
	Local cQueryPK		:= ""
	Local cTabela		:= ""
	Local cTrue			:= .T.
	Local aJson			:= {}
	Local nPos			as NUMERIC
	
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
		
		//TPESAGSX3 := 'SX3'
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('code')
		Else
			cCod := cCodId
		EndIf
		
		Self:oEaiObjSnd:Activate()
		Self:oEaiObjSn2:Activate()		
		
		lNext := .T.
		aRetAlias := Self:CreateQuery(cCod)
		cAliasSX3 := aRetAlias[1]
		
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
			if !(cAliasSX3->(EOF()))
				While !(cAliasSX3->(EOF()))
					For nJ := 1 to Len(aSelFields)		
						cField := aSelFields[nJ]
						cValue := iif(Self:oFieldsJson[cField] = NIL, NIL, cAliasSX3->&(Self:oFieldsJson[cField]))
						
						if cValue != NIL
							if nJ == 1
								Aadd(aJson,JsonObject():new())
							endif
							nPos := Len(aJson)
							aJson[nPos][cField ] := ALLTRIM(NOACENTO(cValue))
						Else
							Self:cError := 'O campo "' + cField + '" não é valido.' + CRLF
							Self:lOk := .F.
							Return()
						EndIf
					Next nJ
					nJ := 1
					Self:oEaiObjSnd:nextItem()
					cAliasSX3->(DbSkip())
				endDo	
				self:oEaiObjSn2:set(aJson)		
			else
				Self:cError := 'Não existe registro com este código.' + CRLF
			endIf
			cAliasSX3->(DBCloseArea())			
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
Method CreateQuery(cCod) CLASS FWfieldsAdapter
	Local lRet 		   as LOGICAL
	Local nX 		   as NUMERIC
	Local cWhere	   as CHARACTER
	Local cOrder	   as CHARACTER
	Local cAliasSX3    as CHARACTER
	Local cQuery	   as CHARACTER
	Local cQuery1	   as CHARACTER
	Local cQuery2	   as CHARACTER
	Local cValOrd	   as CHARACTER
	Local cValWhe      as CHARACTER
	Local aTemp		   as ARRAY	
	Local aRet		   as ARRAY
	
	lRet 		:= .T.
	cAliasSX3 	:= GetNextAlias()
	cWhere 		:= ""
	cOrder		:= ""
	cValWhe		:= ""
	
	if SELECT(cAliasSX3) > 0
		cAliasSX3->(dbCloseArea())
		cAliasSX3 	:= GetNextAlias()
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
			cWhere := "and X3_ARQUIVO = '" + aRet[1] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('code')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('code'), "|" )
			cWhere := "and X3_ARQUIVO = '" + aRet[1] + "' "
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		
		cQuery1 := "select SX3.* "
		cQuery2 := " from " + RetSqlName("SX3") + " SX3 "
		cQuery2 += " WHERE SX3.X3_ARQUIVO in (" + "'NJ0','NJU', 'NNR'" + ")"
		cQuery2 += " and (SX3.X3_CAMPO in "
		cQuery2 += " (" + "'NJ0_CODENT', 'NJ0_LOJENT', 'NJU_CODSAF', 'NNR_CODIGO')"
		cQuery2 += " ) "
		cQuery2 += " and SX3.D_E_L_E_T_ = ' ' "
		cQuery2 += " " + cWhere + " " 		
		
		if !(EMPTY(cOrder))
			cQuery2 += " ORDER BY " + cOrder + " , SX3.X3_ARQUIVO, SX3.X3_ORDEM  "
		else
			cQuery2 += " order by SX3.X3_ARQUIVO, SX3.X3_ORDEM "
		endif
		
		cQuery := cQuery1+cQuery2
		
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"cAliasSX3",.F.,.T.)
		
		if !EMPTY(cValWhe)
			if GETDATASQL("SELECT  COUNT(*)" + cQuery2) > 1
				self:cTipRet = '1'
			else
				self:cTipRet = '2'
			endIf
		endIf
		
		If !Empty(cCod)
			aRet := StrTokArr( cCod, "|" ) // veio do get 
			cWhere := "and X3_ARQUIVO = '" + aRet[1]
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('code')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('code'), "|" )
			cWhere := "and X3_ARQUIVO = '" + aRet[1]
		endIf
		
	else
		Self:lOk := .F.
	EndIf
Return {cAliasSX3}