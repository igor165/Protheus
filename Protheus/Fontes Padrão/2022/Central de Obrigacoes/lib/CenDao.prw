#INCLUDE "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'

#Define DBFIELD 1
#Define JSONFIELD 2

#DEFINE SQLSERVER  "MSSQL"
#DEFINE ORACLE "ORACLE"
#DEFINE POSTGRES "POSTGRES"

/*/{Protheus.doc}
    Classe abstrata que faz o controle de abertura e fechamento e posicionamento de alias
    @type  Class
    @author everton.mateus
    @since 29/11/2017
    @version version
/*/

Class CenDao

	Data cQuery
	Data cAlias
	Data cAliasTemp
	Data cNumPage
	Data cPageSize
	Data cDB
	Data cFields
	Data cfieldOrder
	Data oHashOrder
	Data aMapBuilder
	Data aFields
	Data oStatement
	Data hMap
	Data cError
	Data lFault

	Method New(aFields) Constructor

	Method destroy()
	Method getQuery()
	Method setValue(cProperty,xData)
	Method getValue(cProperty)
	Method setHMap(hMap)
	Method setNumPage(cNumPage)
	Method setPageSize(cPageSize)
	Method getNumPage()
	Method getPageSize()
	Method getRowControl()
	Method getWhereRow()
	Method getQryPage()
	Method setQuery(cQuery)
	Method getAliasTemp()
	Method getAlias()
	Method aliasSelected()
	Method executaQuery()
	Method execStatement()
	Method fechaQuery()
	Method verificaPos(nRecno)
	Method getTypeOpe(lExiste, nType)
	Method posReg(nRecno)
	Method posDbRecno(nRecno)
	Method getDbRecno()
	Method setOrder(cOrder)
	Method queryBuilder(cQuery)
	Method buscar()
	Method insert()
	Method delete()
	Method superDel()
	Method getFields()
	Method getAFields()
	Method getAliasFilial()
	Method getFilters()
	Method normalizeType(xPointer,xValue)
	Method toString(xValue)
	Method toDate(xValue)
	Method toInt(xValue)
	Method hasNext(nRecno)
	Method setError(cMsg)
	Method getError()
	Method atuStatGrp(cStatus, cWhere)
	Method atuStatusByRecno(cStatus, nRecno)
	Method setFields(aFields)

EndClass

Method New(aFields) Class CenDao
	self:oStatement := FWPreparedStatement():New()
	self:oHashOrder := THashMap():New()
	self:hMap 		:= THashMap():New()
	self:aMapBuilder:= {}
	self:aFields 	:= aFields
	self:cDB 		:= TcGetDB()
	self:cNumPage 	:= "1"
	self:cPageSize 	:= "0"
	self:cFields 	:= ""
	self:cfieldOrder:= ""
	self:cError     := ""
Return self

Method destroy() Class CenDao
	self:fechaQuery()
	if !empty(self:hMap)
		self:hMap:clean()
		FreeObj(self:hMap)
		self:hMap := nil
	endif
	if !empty(self:oHashOrder)
		self:oHashOrder:clean()
		FreeObj(self:oHashOrder)
		self:oHashOrder := nil
	endif
	if !empty(self:oStatement)
		self:oStatement:destroy()
		FreeObj(self:oStatement)
		self:oStatement := nil
	endif

Return

Method getQuery() Class CenDao
Return self:cQuery

Method setValue(cProperty,xData) Class CenDao
	Local nPos := 0
	nPos := aScan(self:getAFields(),{ |aFields| aFields[DBFIELD] == cProperty })
	If nPos > 0
		cProperty := self:getAFields()[nPos][JSONFIELD]
	EndIf
Return self:hMap:set(cProperty,xData)

Method getValue(cProperty) Class CenDao
	Local xValue := ""
	Local xDbValue := ""
	Local nPos := 0
	self:hMap:get(cProperty,@xValue)
	If Empty(xValue)
		nPos := aScan(self:getAFields(),{ |aFields| aFields[DBFIELD] == cProperty })
		If nPos > 0
			xDbValue := self:getValue(self:getAFields()[nPos][JSONFIELD])
			If !Empty(xDbValue)
				xValue := xDbValue
			EndIf
		EndIf
	EndIf
Return xValue

Method setHMap(hMap) Class CenDao
	self:hMap := hMap
Return

Method setNumPage(cNumPage) Class CenDao
	self:cNumPage := cNumPage
Return

Method setPageSize(cPageSize) Class CenDao
	self:cPageSize := cPageSize
Return

Method getNumPage() Class CenDao
Return self:cNumPage

Method getPageSize() Class CenDao
Return self:cPageSize

Method getRowControl() Class CenDao

	Local cQuery := ""

	// Para fazer o controle da paginação em SQL, usado dessa maneira porque OFFSET e FETCH não funciona em versões sql menor que 2012
	If SQLSERVER $ self:cDB .Or. ORACLE  $ self:cDB
		cQuery += " WITH " + self:cAlias + " AS ( SELECT ROW_NUMBER() OVER(ORDER BY " + self:cfieldOrder + " ) AS ROW#, "
	Else
		cQuery += " SELECT "
	EndIf

Return cQuery

Method getWhereRow() Class CenDao

	Local cQuery := ""
	Local cNumIni := alltrim(str((val(self:cNumPage ) - 1) * val(self:cPageSize)))
	Local cNumFim := alltrim(str(((val(self:cNumPage )) * val(self:cPageSize)) + 1))

	// Para fazer o controle da paginação em SQL, usado dessa maneira porque OFFSET e FETCH não funciona em versões sql menor que 2012
	If self:cDB <> "POSTGRES"
		cQuery += " ) SELECT * FROM " + self:cAlias
		If val(self:cPageSize) > 0
			cQuery += " WHERE ROW# > " + cNumIni
			cQuery += "  AND ROW# <= " + cNumFim
		EndIf
	EndIf

Return cQuery

Method getQryPage() Class CenDao

	Local cQuery := ""
	Local cNumPage := alltrim(str((val(self:cNumPage ) - 1) * val(self:cPageSize)))

	//Nesse ponto, pegamos sempre 1 registro a mais do tamanho da pÃ¡gina para efeitos de paginaÃ§Ã£o na tela.
	cQuery += " OFFSET " + cNumPage + " ROWS FETCH NEXT " + SOMA1(self:cPageSize) + " ROWS ONLY "

Return cQuery

Method setQuery(cQuery) Class CenDao
	self:cQuery := cQuery
Return

Method getAliasTemp() Class CenDao
	if empty(self:cAliasTemp)
		self:cAliasTemp := getNextAlias()
	endif
Return self:cAliasTemp

Method getAlias() Class CenDao
Return self:cAlias

Method aliasSelected() Class CenDao
Return Select(self:getAliasTemp()) > 0

Method executaQuery() Class CenDao
	Local lFound := .F.

	self:fechaQuery()
	self:setQuery(self:getQuery())
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,self:getQuery()),self:getAliasTemp(),.F.,.T.)
	/*
		Essa linha serve para conferirmos se todos os alias abertos foram fechados.
		Nos codereviews devemos: Descomentar, compilar, fechar o server, apagar o appserver.log,
		abrir o server, rodar o autorizadortestsuite, abrir o appserver.log e
		conferir se o total de :abriu == total de :fechou
	*/
	//conout(self:getAliasTemp()+":abriu:"+procName(6)+">"+procName(5)+">"+procName(4)+">"+procName(3)+">"+procName(2)+">"+procName(1)+": "+self:getQuery())
	lFound := (self:getAliasTemp())->(!Eof())
	If !lFound
		self:fechaQuery()
	EndIf

Return lFound

Method execStatement() Class CenDao
	Local lSuccess := .F.

	lSuccess := TcSqlExec(self:getQuery()) >= 0
	If lSuccess .AND. SubStr(Alltrim(Upper(TCGetDb())),1,6) == "ORACLE"
		lSuccess := TCSQLEXEC("COMMIT") >= 0
	Endif

	If !lSuccess
		self:setError(TcSqlError())
	EndIf

Return lSuccess

Method fechaQuery() Class CenDao
	if self:aliasSelected()
		(self:getAliasTemp())->(dbCloseArea())
		/*
			Essa linha serve para conferirmos se todos os alias abertos foram fechados.
			Nos codereviews devemos: Descomentar, compilar, fechar o server, apagar o appserver.log,
			abrir o server, rodar o autorizadortestsuite, abrir o appserver.log e conferir se o total de :abriu == total de :fechou
		*/
		//conout(self:getAliasTemp()+":fechou:"+procName(6)+">"+procName(5)+">"+procName(4)+">"+procName(3)+">"+procName(2)+">"+procName(1)+": "+self:getQuery())
	endIf
Return

Method verificaPos(nRecno) Class CenDao

	If  self:aliasSelected() .and. nRecno != (self:getAliasTemp())->(RECNO())
		self:posReg(nRecno)
	EndIf

Return

Method posReg(nRecno) Class CenDao
	Local nSkip := 0
	If self:aliasSelected()
		If nRecno < (self:getAliasTemp())->(RECNO())
			(self:getAliasTemp())->(dbGoTop())
			If nRecno <> 1
				nSkip := nRecno-1
			EndIf
		Else
			nSkip := nRecno-(self:getAliasTemp())->(RECNO())
		EndIf
		If nRecno <> 1
			(self:getAliasTemp())->(dbSkip(nSkip))
		EndIf
		self:posDbRecno((self:getAliasTemp())->RECNO)
	EndIf
Return

Method posDbRecno(nRecno) Class CenDao
	If nRecno <> self:getDbRecno()
		(self:cAlias)->(DbGoto(nRecno))
	EndIf
Return !(self:cAlias)->(Eof())

Method getDbRecno() Class CenDao
Return (self:cAlias)->(RECNO())

Method setOrder(cOrder) Class CenDao
	Local aOrder	:= {}
	Local nField	:= 0
	Local nLen		:= 0
	Local nPos		:= 0
	Local cField	:= ""
	Local cTypeOrder := " ASC "

	If !Empty(cOrder)
		aOrder = StrTokArr(cOrder, "," )
		self:cfieldOrder := ""
		nLen := Len( aOrder )
		For nField := 1 to nLen
			cField := UPPER(aOrder[nField])
			If SubStr(cField,1,1) == "-"
				cField := SubStr(cField, 2, LEN(cField))
				cTypeOrder := " DESC "
			EndIf
			If self:oHashOrder:get(cField)
				self:oHashOrder:get(cField, cField)
				self:cfieldOrder += IIf(Empty(self:cfieldOrder),""," , ") + cField + cTypeOrder
			Else
				nPos := aScan(self:aFields, {|aField|  UPPER(aField[2]) == cField })
				If nPos > 0
					self:cfieldOrder += IIf(Empty(self:cfieldOrder),""," , ") + self:aFields[nPos,DBFIELD] + cTypeOrder
				EndIf
			EndIf
		Next nField
	EndIf
Return

Method queryBuilder(cQuery) Class CenDao

	Local nStatement := 1
	Local cQryFixed := ""

	self:oStatement:SetQuery(cQuery)

	For nStatement:= 1 to Len(self:aMapBuilder)
		self:oStatement:SetString( nStatement , self:aMapBuilder[nStatement])
	Next

	cQryFixed := self:oStatement:GetFixQuery()

	self:aMapBuilder := nil
	self:aMapBuilder := {}

	self:oStatement:destroy()
	FreeObj(self:oStatement)
	self:oStatement := nil
	self:oStatement :=  FWPreparedStatement():New()

Return cQryFixed

Method buscar() Class CenDao

	Local cQuery := ""
	Local lFound := .F.

	cQuery += self:getRowControl()
	cQuery += self:getFields()
	cQuery += " FROM " + RetSqlName(self:cAlias) + " " + self:cAlias + " "
	cQuery += self:getFilters()
	cQuery := self:queryBuilder(cQuery)
	cQuery += self:getWhereRow()

	self:setQuery(cQuery)
	lFound := self:executaQuery()

Return lFound

Method insert() Class CenDao
	Local lFound := !self:bscChaPrim()
	If lFound
		self:commit(.T.)
	EndIf
Return lFound

Method delete() Class CenDao
	Local lFound := .F.

	if (self:cAlias)->(recLock((self:cAlias),.F.))
		(self:cAlias)->(dbDelete())
		(self:cAlias)->(msUnLock())
		lFound := .T.
	endIf

Return lFound

Method superDel() Class CenDao
	Local cQuery := ""
	Local lFound := .F.

	cQuery := " DELETE FROM "
	cQuery += " " + RetSqlName(self:cAlias) + " "
	cQuery += self:getFilters()
	cQuery := self:queryBuilder(cQuery)
	self:setQuery(cQuery)
	lFound := self:execStatement()

Return lFound

Method getAFields() Class CenDao
Return self:aFields

Method getFields() Class CenDao

	Local nField := 0
	Local nLen   := Len(self:getAFields())

	If empty(self:cFields)
		For nField := 1 to nLen
			self:cFields += IIf(nField > 1," , ","") + self:getAFields()[nField][DBFIELD] + " "
		Next nField
		self:cFields += " ,R_E_C_N_O_ RECNO "
	EndIf

Return self:cFields

Method getAliasFilial() Class CenDao
	Local cAlias := self:cAlias
	if SubStr(self:cAlias,1,2) == 'SX' .OR. self:cAlias ==  'SIX'
		cAlias := ""
	ElseIf SubStr(self:cAlias,1,1) == 'S'
		cAlias := SubStr(self:cAlias,2,2)
	EndIf
Return cAlias

Method getFilters() Class CenDao

	Local cFilter := ""
	Local xValue  := ""
	Local nField := 0
	Local nLen   := Len(self:getAFields())
	Local cAliasFilial := IIf(SubStr(self:cAlias,1,1) == 'S',SubStr(self:cAlias,2,2), self:cAlias)

	cFilter += " WHERE "
	cFilter += " "+ cAliasFilial + "_FILIAL = '" + xFilial( self:cAlias ) + "' "

	For nField := 1 to nLen
		xValue := self:getValue(self:getAFields()[nField][JSONFIELD])
		If !empty(xValue)
			cFilter += " AND " + self:getAFields()[nField][DBFIELD] + " = ? "
			aAdd(self:aMapBuilder, self:toString(xValue))
		EndIf
	Next nField

	cFilter += " AND D_E_L_E_T_ = ? "
	aAdd(self:aMapBuilder, ' ')

Return cFilter

Method normalizeType(xPointer,xValue) Class CenDao

	Local cValue := ""

	if ValType( xPointer ) == "C"
		cValue := self:toString(xValue)
	ElseIf ValType( xPointer ) == "N"
		cValue := self:toInt(xValue)
	ElseIf ValType( xPointer ) == "D"
		cValue := self:toDate(xValue)
	EndIf

Return cValue

Method toString(xValue) Class CenDao
	Local cValue := ""

	If xValue == Nil
		cValue := ""
	ElseIf ValType( xValue ) == "N"
		cValue := AllTrim(Str(xValue))
	ElseIf ValType( xValue ) == "C"
		cValue := xValue
	ElseIf ValType( xValue ) == "D"
		cValue := DTOS(xValue)
	EndIf

Return cValue

Method toDate(xValue) Class CenDao

	Local cValue := ""

	If xValue == Nil
		cValue := STOD("")
	ElseIf ValType( xValue ) == "D"
		cValue := xValue
	ElseIf ValType( xValue ) == "C"
		cValue := STOD(xValue)
	EndIf

Return cValue

Method toInt(xValue) Class CenDao

	Local cValue := ""

	If xValue == Nil
		cValue := VAL("")
	ElseIf ValType( xValue ) == "N"
		cValue := xValue
	ElseIf ValType( xValue ) == "C"
		cValue := VAL(xValue)
	EndIf

Return cValue

Method hasNext(nRecno) Class CenDao
	Local lTemProx := .F.
	If self:aliasSelected()
		self:verificaPos(nRecno)
		lTemProx := !(self:getAliasTemp())->(Eof())
	EndIf
return lTemProx

Method setError(cMsg) Class CenDao
	self:cError := cMsg
	self:lFault := .T.
	conout(self:cError)
return

Method getError() Class CenDao
return self:cError

Method atuStatGrp(cStatus,cAlias,cWhere) Class CenDao
	Local cQuery := ""
	Local lFound := .F.

	cQuery := " UPDATE "
	cQuery += " " + RetSqlName(cAlias) + " "
	cQuery += " SET " + cAlias + "_STATUS='"+cStatus+"' "
	cQuery += " WHERE 1=1 "
	cQuery += " AND "+ cAlias + "_FILIAL = '" + xFilial( cAlias ) + "' "
	cQuery += cWhere
	cQuery += " AND D_E_L_E_T_ = ' ' "

	self:setQuery(cQuery)
	lFound := self:execStatement()

Return lFound

Method atuStatusByRecno(cStatus, nRecno) Class CenDao
	Local cQuery := ""
	Local lFound := .F.

	cQuery := " UPDATE "
	cQuery += " " + RetSqlName(self:cAlias) + " "
	cQuery += " SET " + self:cAlias + "_STATUS='"+cStatus+"' "
	cQuery += " WHERE 1=1 "
	cQuery += " AND R_E_C_N_O_ = '" + AllTrim(Str(nRecno)) + "' "

	self:setQuery(cQuery)
	lFound := self:execStatement()

Return lFound

Method setFields(aFields) Class CenDao
	self:aFields := aFields
Return