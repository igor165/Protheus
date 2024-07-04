#INCLUDE "protheus.ch"
#INCLUDE "fwbrowse.ch"
#INCLUDE "parmtype.ch"
#INCLUDE "fwmvcdef.ch"
#INCLUDE "apwizard.ch"
#INCLUDE "fileio.ch"
#INCLUDE "topconn.ch"
#INCLUDE "fwadaptereai.ch"

Class FWdataAdapter   
	
	DATA lApi        		as LOGICAL
	DATA lOk		 		as LOGICAL

	DATA cRecno 	  		as CHARACTER
	DATA cBranch 	  		as CHARACTER
	DATA cCode	 	  		as CHARACTER
	DATA cDescription 		as CHARACTER
	DATA cdata				as CHARACTER
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
	DATA oFieldsEntityHe    as OBJECT

	METHOD NEW()	
	METHOD Getdata()
	METHOD GetNames()
	
	METHOD CreateQuery()
	
EndClass

/*/{Protheus.doc} NEW
Responsável instanciar um objeto FWEAIObj e seus devidos atributos. 
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@type function

/*/
Method NEW() CLASS FWdataAdapter
	Self:lApi	:= .F.
	Self:lOk	:= .F.
	
	Self:cRecno 	  		:= ''
	Self:cBranch 	  		:= ''
	Self:cCode	 	  		:= ''
	Self:cDescription 		:= ''
	Self:cdata		   	:= ''
	Self:cInternalId  		:= ''
	Self:cError       		:= ''
	Self:cMsgName     		:= 'TPESAG'
	Self:cSelectedFields 	:= ''
	Self:cTipRet		 	:= '' //Tipo de retorno -> 1 = Array; 2 = NãoArray 
	//
	self:oFieldsJson  		:= JsonObject():New()
	self:oArrayJson	  		:= self:GetNames()[1]
	self:oFieldsEntityHe  	:= JsonObject():New()
	
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
Method GetNames() CLASS FWdataAdapter
	
	oArrayJson := &('JsonObject():New()')
	oFieldsJson := &('JsonObject():New()')
	
	oFieldsJson['id']						:= 'X3_ARQUIVO'
	oFieldsJson['code']						:= 'X3_ARQUIVO'
	oFieldsJson['description']			    := 'X2_NOME'
	oFieldsJson['abbreviatedDescription']	:= 'X2_NOME'
	oFieldsJson['tableStatus']			    := ''
	oFieldsJson['schedule']			    	:= ''
	
	oArrayJson['id']						:= 'X3_CAMPO'
	oArrayJson['name']						:= 'X3_CAMPO'
	oArrayJson['description']				:= 'X3_DESCRIC'
	oArrayJson['dataType']					:= 'X3_TIPO'
	oArrayJson['size']						:= 'X3_TAMANHO'
	oArrayJson['decimals'] 					:= 'X3_DECIMAL'
	oArrayJson['fgNull'] 					:= 'X3_OBRIGAT'
	oArrayJson['fgPK'] 						:= ''
	oArrayJson['fgFK'] 						:= ''
	oArrayJson['showConsult'] 				:= ''
	oArrayJson['instance'] 					:= ''
	oArrayJson['header'] 					:= 'X3_ARQUIVO'
	
return {oArrayJson}

/*/{Protheus.doc} Getdata
//Responsável por trazer a busca das safras
@author Iuri Bruning Negherbon
@since 28/01/2020
@version 1.0
@return lRet, lógico de validação
@param cCodId, characters, Código único do conjunto
@type function
/*/
Method Getdata(cCodId) CLASS FWdataAdapter
	Local lNext     	as LOGICAL
	Local lRet			as LOGICAL
	Local lFields		as LOGICAL
	Local nCount     	as NUMERIC
	Local nJ			as NUMERIC
	Local nX			as NUMERIC
	Local cError       	as CHARACTER
	Local cAliasSX3 	as CHARACTER
	Local cAliasPK		as CHARACTER
	Local cCodId 	    as CHARACTER
	Local cCod	 	    as CHARACTER
	Local cQuery 	    as CHARACTER
	Local cField		as CHARACTER
	Local aSelFields	as ARRAY
	Local oPage      	as OBJECT
	Local oTempJson    	as OBJECT
	Local cQueryPK		:= ""
	Local cTabela		:= ""
	Local cTrue			:= .T.
	Local cTipo			as CHARACTER
	Local cPK			as CHARACTER
	Local cValorPk 		as CHARACTER
	
	aSelFields 	:= NIL
	nJ		 	:= 1
	nX			:= 1
	lRet     	:= .T.
	lFields		:= .F.
	cQuery 	 	:= ''
	cError   	:= ''		
	nCount   	:= 0
	oTempJson	:= &('JsonObject():New()')
	cPK 		:= ''
	cValorPk	:= ''
	
	if Self:lApi
		if !(EMPTY(Self:oEaiObjRec:GetPage()))
			oPage:=FwPageCtrl():New(Self:oEaiObjRec:GetPageSize(),Self:oEaiObjRec:GetPage())
		EndIf
		
		If Empty(cCodId)
			cCod := Self:oEaiObjRec:getPathParam('code')
		Else
			cCod := cCodId
		EndIf
		
		Self:oEaiObjSnd:Activate()		
		self:oEaiObjSn2:Activate()
		Self:oFieldsJson:Activate()
		Self:oFieldsEntityHe:Activate()
		
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
			cTabela := cAliasSX3->(X3_ARQUIVO)
			
			self:oFieldsJson['entityHe'] := Self:oFieldsEntityHe
	 		Self:oFieldsEntityHe['id'] 						:=		ALLTRIM(cAliasSX3->(X3_ARQUIVO))
	 		Self:oFieldsEntityHe['code'] 					:=		ALLTRIM(cAliasSX3->(X3_ARQUIVO))
	 		Self:oFieldsEntityHe['description'] 			:=		ALLTRIM(cAliasSX3->(X2_NOME))
	 		Self:oFieldsEntityHe['abbreviatedDescription'] 	:=		ALLTRIM(cAliasSX3->(X2_NOME))
	 		Self:oFieldsEntityHe['tableStatus'] 			:=		'A'
	 		Self:oFieldsEntityHe['schedule'] 				:=		'N'
			
			self:oFieldsEntityHe['listDetails'] := {}
			Aadd(self:oFieldsEntityHe['listDetails'], JsonObject():New())
			
			nX := 1
			while cTrue
				if nX != 1
					Aadd(self:oFieldsEntityHe['listDetails'], JsonObject():New())
				endif 
			 	
			 	if cAliasSX3->(X3_TIPO) = 'C' .or. cAliasSX3->(X3_TIPO) = 'M'
					cTipo := 'V'
				else
					cTipo := cAliasSX3->(X3_TIPO)
				endif
			 		
		 		Self:oFieldsEntityHe['listDetails'][nX]['id'] 				:=		ALLTRIM(cAliasSX3->(X3_CAMPO))
		 		Self:oFieldsEntityHe['listDetails'][nX]['name'] 			:=		ALLTRIM(cAliasSX3->(X3_CAMPO))
		 		Self:oFieldsEntityHe['listDetails'][nX]['description'] 		:=		ALLTRIM(cAliasSX3->(X3_DESCRIC))
		 		Self:oFieldsEntityHe['listDetails'][nX]['dataType'] 		:=		ALLTRIM(cTipo)
		 		Self:oFieldsEntityHe['listDetails'][nX]['size'] 			:=		cAliasSX3->(X3_TAMANHO)
		 		Self:oFieldsEntityHe['listDetails'][nX]['decimals'] 		:=		cAliasSX3->(X3_DECIMAL)
		 		Self:oFieldsEntityHe['listDetails'][nX]['fgNull'] 			:=		iif(alltrim(cAliasSX3->(X3_OBRIGAT)) = 'x','S','N')
		 		
		 		cAliasPK 	:= GetNextAlias()
		 		cQueryPK := "SELECT COUNT(*) as PK FROM SX2T10 WHERE X2_CHAVE = '"+cAliasSX3->(X3_ARQUIVO)+"' AND X2_UNICO LIKE '%" + cAliasSX3->(X3_CAMPO) + "%'"
		 		cQueryPK := ChangeQuery(cQueryPK)
		 		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQueryPK),"cAliasPK",.F.,.T.)
		 		
		 		if cAliasPK->PK = 1
		 			cPK += (cAliasSX3->(X3_CAMPO))//cAliasSX3->(X3_CAMPO)
		 		endif		 		
		 		
		 		//if cAliasPK->PK = 1 .and. SUBSTR(cAliasSX3->(X3_CAMPO),5,3) = 'COD'
		 		if ALLTRIM(cAliasSX3->(X2_NOME)) == 'PK'
		 			Self:oFieldsEntityHe['listDetails'][nX]['fgPK']  := 'S' 
		 		else
		 			Self:oFieldsEntityHe['listDetails'][nX]['fgPK']  := 'N'
		 		endif
		 		
		 		cAliasPK->(DBCloseArea())

		 		Self:oFieldsEntityHe['listDetails'][nX]['fgFK']			:=	'{}'
		 		Self:oFieldsEntityHe['listDetails'][nX]['showConsult']	:=	'N'
		 		Self:oFieldsEntityHe['listDetails'][nX]['instance']		:=	'N'
		 		Self:oFieldsEntityHe['listDetails'][nX]['header']		:=	cAliasSX3->(X3_ARQUIVO)
				
		 		cAliasSX3->(DbSkip())
		 		nX++
		 		if cAliasSX3->(X3_ARQUIVO) <> cTabela
		 			cTrue := .F.
		 		endif
			end
			
			self:oFieldsJson['listRow'] := {}
			Aadd(self:oFieldsJson['listRow'], JsonObject():New())			
			
			cContReg := 1
			dbSelectArea(cCod)			
			dbSetOrder(1)
			DBGOTOP()
			while !Eof()
				//if (cCod == 'NNR' .and. ALLTRIM(NNR_FILIAL) == 'D MG') .or. (cCod <> 'NNR')
					if cContReg != 1
						Aadd(self:oFieldsJson['listRow'], JsonObject():New())
					endif
					cValorPK := ''
					
					Self:oFieldsJson['listRow'][cContReg]['idRow'] := cContReg
					Self:oFieldsJson['listRow'][cContReg]['listColumn'] :=  {}
					
					cAliasSX3->(dbGotop())
					nx := 1
					while !(cAliasSX3->(EOF()))
						Aadd(self:oFieldsJson['listRow'][cContReg]['listColumn'], JsonObject():New())
						Self:oFieldsJson['listRow'][cContReg]['listColumn'][nX]['idColumn']	:=	ALLTRIM(cAliasSX3->(X3_CAMPO))
						if ALLTRIM(cAliasSX3->(X2_NOME)) == 'PK'
							if EMPTY(cValorPK)
								Self:oFieldsJson['listRow'][cContReg]['listColumn'][nX]['value'] 	:= cContReg
							else
								Self:oFieldsJson['listRow'][cContReg]['listColumn'][nX]['value']	:=	cValorPk
							endif
						elseif VALTYPE(&(cAliasSX3->(X3_CAMPO))) == 'D'
							Self:oFieldsJson['listRow'][cContReg]['listColumn'][nX]['value']	:= FWTimeStamp(5,&(cAliasSX3->(X3_CAMPO)),'00:00:00')
						else
							Self:oFieldsJson['listRow'][cContReg]['listColumn'][nX]['value']	:=	ALLTRIM(&(cAliasSX3->(X3_CAMPO)))
							if ALLTRIM(cAliasSX3->(X3_CAMPO)) $ cPK
								cValorPk += &(cAliasSX3->(X3_CAMPO))
							endif								
						endif
						cAliasSX3->(DbSkip())
						nx++
					end
					cContReg++
				//endif
				dbSkip()
			end							
		else 
			Self:cError := 'Não existe registro com este código.' + CRLF
			Self:lOk	:= .F.
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
Method CreateQuery(cCod) CLASS FWdataAdapter
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
			cWhere := " and X3_ARQUIVO = '" + aRet[1] + "' "
		elseif !EMPTY(Self:oEaiObjRec:getPathParam('code')) //veio do get por ID
			aRet := StrTokArr( Self:oEaiObjRec:getPathParam('code'), "|" )
			cWhere := " and X3_ARQUIVO = '" + aRet[1] + "' "
		endIf	
	Endif
	
	if lRet
		Self:lOk := .T.
		
		//cQuery1 := "select SX3.*, SX2.X2_NOME "
		cQuery1 := " select SX3.X3_ARQUIVO, SX3.X3_CAMPO, SX3.X3_DESCRIC, SX3.X3_TIPO, "
		cQuery1 += " SX3.X3_TAMANHO, SX3.X3_DECIMAL, SX3.X3_OBRIGAT, SX2.X2_NOME, SX3.X3_ORDEM "
		cQuery2 := " from " + RetSqlName("SX3") + " SX3 "
		cQuery2 += " LEFT OUTER JOIN " + RetSqlName("SX2") + " SX2 ON SX2.X2_CHAVE = SX3.X3_ARQUIVO and SX2.D_E_L_E_T_ = ' ' "
		cQuery2 += " WHERE SX3.X3_ARQUIVO in ('NJ0','NJU','NNR')"
		cQuery2 += " and SX3.X3_CAMPO in "
		cQuery2 += " ('NJ0_FILIAL', 'NJ0_CGC', 'NJ0_CODENT', 'NJ0_LOJENT', 'NJ0_NOME', "
		cQuery2 += " 'NJU_FILIAL', 'NJU_CODSAF', 'NJU_DESCRI', "
		cQuery2 += " 'NNR_FILIAL', 'NNR_CODIGO', 'NNR_DESCRI')"
		cQuery2 += " and SX3.D_E_L_E_T_ = ' ' "
		cQuery2 += " " + cWhere + " "
		cQuery2 += " UNION "
		cQuery2 += " SELECT '" + cCod + "' AS X3_ARQUIVO, 'PK_"+cCod+"' AS X3_CAMPO, 'PK' AS X3_DESCRIC, 'C' AS X3_TIPO, "
		cQuery2 += " '50' AS X3_TAMANHO, '0' AS X3_DECIMAL, 'x' AS X3_OBRIGAT, 'PK' AS X3_NOME, '99' AS X3_ORDEM "
		cQuery2 += " FROM " + RetSqlName(cCod)
		
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
