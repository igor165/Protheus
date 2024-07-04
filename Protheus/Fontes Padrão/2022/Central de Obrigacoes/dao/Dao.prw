#include "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE LOTE "06"

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

Class Dao

	Data cQuery
	Data cAliasTemp
	Data lAliasSelect
	Data cCodOpe
	Data cNumPage
	Data cPageSize
	Data cDB
	Data cFields
	Data cfieldOrder
	Data oHashOrder
	Data aMapBuilder
    Data oStatement        

	Method New() Constructor

	Method getQuery()
    Method getAlias()
    Method getQtd()
	Method getAliasTemp()
	Method getAliasSelect()
	Method getGetter()
	Method getRowControl(fieldOrder,cAlias) 
	Method getWhereRow(cAlias) 
	Method getTypeOpe(lExiste, nType) 

	Method setQuery()
	Method setAlias()
	Method setOrder(cOrder)

	Method getCodOpe()
	Method setCodOpe()

	Method setNumPage(cNumPage)
	Method setPageSize(cPageSize)

	Method getNumPage()
	Method getPageSize()
	Method getQryPage()
	
	Method executaQuery()	
	Method fechaQuery() 

	Method posReg(nRecno)

	Method verificaPos(nRecno)
	Method queryBuilder(cQuery)

	Method Destroy()

EndClass

Method New() Class Dao
	lAliasSelect := .F.
	self:cDB := TcGetDB()
	self:oHashOrder := THashMap():New()
	self:aMapBuilder := {}
    self:oStatement :=  FWPreparedStatement():New()
	self:cNumPage := "1"
	self:cPageSize := "20"
Return self

Method Destroy() Class Dao

	if self:oHashOrder <> nil
		FreeObj(self:oHashOrder)
		self:oHashOrder := Nil
	EndIf
	
	if self:oStatement <> nil
		FreeObj(self:oStatement)
		self:oStatement := Nil
	EndIf
	
	if self:aMapBuilder <> nil
		aMapBuilder := nil
	EndIf

	self:fechaQuery()
	DelClassIntf()
	
Return

Method getQuery() Class Dao
Return self:cQuery

Method getCodOpe() Class Dao
	if empty(self:cCodOpe)
		self:setCodOpe("0001")
	endIf
Return self:cCodOpe

Method setCodOpe(cCodOpe) Class Dao
	self:cCodOpe := cCodOpe
Return

Method setNumPage(cNumPage) Class Dao
    self:cNumPage := cNumPage 
Return

Method setPageSize(cPageSize) Class Dao
    self:cPageSize := cPageSize
Return

Method getNumPage() Class Dao
Return self:cNumPage

Method getPageSize() Class Dao
Return self:cPageSize

Method getRowControl(fieldOrder,cAlias) Class Dao

	Local cQuery := ""
	
	// Para fazer o controle da paginação em SQL, usado dessa maneira porque OFFSET e FETCH não funciona em versões sql menor que 2012
	If SQLSERVER $ self:cDB
		cQuery += " WITH " + cAlias + " AS ( SELECT ROW_NUMBER() OVER(ORDER BY " + fieldOrder + " ) AS ROW#, "
	ElseIf POSTGRES $ self:cDB
		cQuery += " WITH " + cAlias + " AS ( SELECT ROW_NUMBER() OVER(ORDER BY " + fieldOrder + " ) AS ROW, "
	Else
		cQuery += " SELECT * FROM ( "
		cQuery += "		SELECT  "
		cQuery += "			ROWNUM AS RN, "
	EndIf

Return cQuery

Method getWhereRow(cAlias) Class Dao
	Local cQuery := ""
	Local cNumIni := alltrim(str((val(self:cNumPage ) - 1) * val(self:cPageSize)))
	Local cNumFim := alltrim(str(((val(self:cNumPage )) * val(self:cPageSize)) + 1))

	// Para fazer o controle da paginação em SQL, usado dessa maneira porque OFFSET e FETCH não funciona em versões sql menor que 2012
	If SQLSERVER $ self:cDB
		cQuery += " ) SELECT  * FROM " + cAlias +" WHERE ROW# > " + cNumIni +" AND ROW# <= " +  cNumFim
	ElseIf ORACLE $ self:cDB
		cQuery += self:getQryPage(cNumIni,cNumFim)
	ElseIf POSTGRES $ self:cDB
		cQuery += " ) SELECT  * FROM " + cAlias +" WHERE ROW > " + cNumIni +" AND ROW <= " +  cNumFim
	EndIf
Return cQuery

Method getQryPage(cNumIni, cNumFim) Class Dao
    Local cQuery := ""
    //Nesse ponto, pegamos sempre 1 registro a mais do tamanho da página para efeitos de paginação na tela.
    cQuery += " ) WHERE 1=1 AND RN > "+ cNumIni +" AND RN <= "+ cNumFim
Return cQuery

Method setQuery(cQuery) Class Dao
	self:cQuery := cQuery
Return

Method getAliasTemp() Class Dao
	if empty(self:cAliasTemp)
		self:cAliasTemp := getNextAlias()
	endif
Return self:cAliasTemp

Method getAliasSelect() Class Dao
Return self:lAliasSelect

Method executaQuery() Class Dao
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
	//conout(self:cAliasTemp+":abriu:"+procName(6)+">"+procName(5)+">"+procName(4)+">"+procName(3)+">"+procName(2)+">"+procName(1)+": "+self:getQuery()) 
	lFound := (self:cAliasTemp)->(!Eof())
	If !lFound
		self:fechaQuery()
	EndIf
	
Return lFound

Method getQtd() Class Dao
Return (self:cAliasTemp)->QTD

Method fechaQuery() Class Dao
	if Select(self:cAliasTemp) > 0  
		(self:cAliasTemp)->(dbCloseArea())
		/*	
			Essa linha serve para conferirmos se todos os alias abertos foram fechados.
			Nos codereviews devemos: Descomentar, compilar, fechar o server, apagar o appserver.log, 
			abrir o server, rodar o autorizadortestsuite, abrir o appserver.log e conferir se o total de :abriu == total de :fechou
		*/
		//conout(self:cAliasTemp+":fechou:"+procName(6)+">"+procName(5)+">"+procName(4)+">"+procName(3)+">"+procName(2)+">"+procName(1)+": "+self:getQuery()) 
	endIf
Return

Method verificaPos(nRecno) Class Dao
	self:lAliasSelect := Select(self:cAliasTemp) > 0
	If  self:lAliasSelect .and. nRecno != (self:cAliasTemp)->(RECNO())
		self:posReg(nRecno)
	EndIf
Return

Method getTypeOpe(lExiste, nType) Class Dao

	Local nOperation := nil

	If (!lExiste .AND. nType == INSERT .OR. nType == LOTE)
        nOperation := MODEL_OPERATION_INSERT
    ElseIf (lExiste .AND. nType == DELETE)
        nOperation := MODEL_OPERATION_DELETE
    ElseIf (lExiste .AND. nType != INSERT .AND. nType != DELETE ) 
        nOperation := MODEL_OPERATION_UPDATE
    EndIf

Return nOperation

Method posReg(nRecno) Class Dao
	Local nSkip := 0
	If nRecno < (self:cAliasTemp)->(RECNO())
		(self:cAliasTemp)->(dbGoTop())
		If nRecno <> 1
			nSkip := nRecno-1
		EndIf
	Else
		nSkip := nRecno-(self:cAliasTemp)->(RECNO())
	EndIf
	If nRecno <> 1
		(self:cAliasTemp)->(dbSkip(nSkip))
	EndIf
Return

Method setOrder(cOrder) Class Dao 
	Local aOrder 
	Local cDesc
	Local nI 	 	 := 0
	Local cField 	 := ""
	Local cTypeOrder := " ASC "

	aOrder = StrTokArr(cOrder, "," )

	If !Empty(cOrder)
		
		For nI := 1 to Len( aOrder )
		
			cField := UPPER(aOrder[nI])
			cDesc = SubStr(cField,1,1)

			If cDesc == "-"
				cField := SubStr(cField, 2, LEN(cField))
				cTypeOrder := " DESC "
			EndIf

			If self:oHashOrder:get(cField)

				self:oHashOrder:get(cField, cField)

				If nI = 1
					self:cfieldOrder := " " + cField + cTypeOrder
				Else
					self:cfieldOrder += " , " + cField + cTypeOrder
				EndIf

			EndIf
		Next nI
	EndIf
Return

Method queryBuilder(cQuery) Class Dao

    Local nX := 1
    Local queyReturn

    self:oStatement:SetQuery(cQuery) 
    
    For nX:= 1 to Len(self:aMapBuilder)
        self:oStatement:SetString( nX , self:aMapBuilder[nX])
    Next

    queyReturn := self:oStatement:GetFixQuery()

    self:aMapBuilder := nil
    self:aMapBuilder := {}

    self:oStatement := nil 
    self:oStatement :=  FWPreparedStatement():New()

Return queyReturn