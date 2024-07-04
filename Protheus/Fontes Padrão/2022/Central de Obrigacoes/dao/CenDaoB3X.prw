#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoB3X from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    Method bscMovCount(cDateIni, cDateFim, cCodeOpe)
    
EndClass

Method New(aFields) Class CenDaoB3X
	_Super:New(aFields)
    self:cAlias := "B3X"
    self:cfieldOrder := "B3X_ARQUIV,B3X_DESORI"
Return self

Method buscar() Class CenDaoB3X
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B3X->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB3X
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB3X

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B3X') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B3X_FILIAL = '" + xFilial("B3X") + "' "

    cQuery += " AND B3X_ARQUIV = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("fileName")))
    cQuery += " AND B3X_DESORI = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("originDescription")))

    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoB3X
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoB3X

    Default lInclui := .F.

	If B3X->(RecLock("B3X",lInclui))
		
        B3X->B3X_FILIAL := xFilial("B3X")
        If lInclui
        
            B3X->B3X_ARQUIV := _Super:normalizeType(B3X->B3X_ARQUIV,self:getValue("fileName")) /* Column B3X_ARQUIV */
            B3X->B3X_DESORI := _Super:normalizeType(B3X->B3X_DESORI,self:getValue("originDescription")) /* Column B3X_DESORI */

        EndIf

        B3X->B3X_BENEF  := _Super:normalizeType(B3X->B3X_BENEF ,self:getValue("benefitedRecno")) /* Column B3X_BENEF  */
        B3X->B3X_CAMPO  := _Super:normalizeType(B3X->B3X_CAMPO ,self:getValue("changedField")) /* Column B3X_CAMPO  */
        B3X->B3X_DATA   := _Super:normalizeType(B3X->B3X_DATA  ,self:getValue("changeDate")) /* Column B3X_DATA   */
        B3X->B3X_OPERA  := _Super:normalizeType(B3X->B3X_OPERA ,self:getValue("sibOperation")) /* Column B3X_OPERA  */
        B3X->B3X_CRITIC := _Super:normalizeType(B3X->B3X_CRITIC,self:getValue("criticized")) /* Column B3X_CRITIC */
        B3X->B3X_HORA   := _Super:normalizeType(B3X->B3X_HORA  ,self:getValue("modificationTime")) /* Column B3X_HORA   */
        B3X->B3X_STATUS := _Super:normalizeType(B3X->B3X_STATUS,self:getValue("status")) /* Column B3X_STATUS */
        B3X->B3X_VLRANT := _Super:normalizeType(B3X->B3X_VLRANT,self:getValue("previousValue")) /* Column B3X_VLRANT */
        B3X->B3X_VLRNOV := _Super:normalizeType(B3X->B3X_VLRNOV,self:getValue("newValue")) /* Column B3X_VLRNOV */
        B3X->B3X_CODOPE := _Super:normalizeType(B3X->B3X_CODOPE,self:getValue("operatorRecord")) /* Column B3X_CODOPE */
        B3X->B3X_CODCCO := _Super:normalizeType(B3X->B3X_CODCCO,self:getValue("operationalControlCode")) /* Column B3X_CODCCO */
        B3X->B3X_DTINVL := _Super:normalizeType(B3X->B3X_DTINVL,self:getValue("validationStartDate")) /* Column B3X_DTINVL */
        B3X->B3X_HRINVL := _Super:normalizeType(B3X->B3X_HRINVL,self:getValue("validationStartTime")) /* Column B3X_HRINVL */
        B3X->B3X_DTTEVL := _Super:normalizeType(B3X->B3X_DTTEVL,self:getValue("validationEndDate")) /* Column B3X_DTTEVL */
        B3X->B3X_HRTEVL := _Super:normalizeType(B3X->B3X_HRTEVL,self:getValue("validationEndTime")) /* Column B3X_HRTEVL */

        B3X->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound

Method bscMovCount(cDateIni, cDateFim, cCodeOpe) Class CenDaoB3X

	Local cQuery := ""
    Local aMovQtd := {0,0,0,0}

    Default cDateIni := ""
    Default cDateFim := ""
    Default cCodeOpe := ""

    cQuery += " SELECT "
    cQuery += "     SUM(INCLUSAO) INCLUSAO, "
	cQuery += "     SUM(RETIFICACAO) RETIFICACAO,  "
	cQuery += "     SUM(MUDCONTRAT) MUDCONTRAT,  "
	cQuery += "     SUM(CANCELAMENTO) CANCELAMENTO "
    cQuery += " FROM ( "
    //Inclusão
    cQuery += " SELECT COUNT(*) INCLUSAO, 0 RETIFICACAO, 0 MUDCONTRAT, 0 CANCELAMENTO  FROM " + RetSqlName('B3X') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " 	AND B3X_OPERA = '1' "
    cQuery += " 	AND B3X_CODOPE = '" + cCodeOpe + "' "
    cQuery += " 	AND B3X_DATA > '" + cDateIni + "' "
    cQuery += " 	AND B3X_DATA < '" + cDateFim + "' "
    cQuery += " UNION ALL "
    //Retificacao
    cQuery += " SELECT 0 INCLUSAO, COUNT(*) RETIFICACAO, 0 MUDCONTRAT, 0 CANCELAMENTO  FROM " + RetSqlName('B3X') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " 	AND B3X_OPERA = '2' "
    cQuery += " 	AND B3X_CODOPE = '" + cCodeOpe + "' "  
    cQuery += " 	AND B3X_DATA > '" + cDateIni + "' "
    cQuery += " 	AND B3X_DATA < '" + cDateFim + "' "
    cQuery += " UNION ALL "
    //Mudança contratual
    cQuery += " SELECT 0 INCLUSAO, 0 RETIFICACAO, COUNT(*)  MUDCONTRAT, 0 CANCELAMENTO  FROM " + RetSqlName('B3X') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " 	AND B3X_OPERA = '3' "
    cQuery += " 	AND B3X_CODOPE = '" + cCodeOpe + "' "  
    cQuery += " 	AND B3X_DATA > '" + cDateIni + "' "
    cQuery += " 	AND B3X_DATA < '" + cDateFim + "' "
    cQuery += " UNION ALL "
    cQuery += " SELECT 0 INCLUSAO, 0 RETIFICACAO, 0 MUDCONTRAT, COUNT(*)  CANCELAMENTO  FROM " + RetSqlName('B3X') + " "
    cQuery += " WHERE 1=1 "
    cQuery += " 	AND B3X_OPERA = '4' "
    cQuery += " 	AND B3X_CODOPE = '" + cCodeOpe + "' "
    cQuery += " 	AND B3X_DATA > '" + cDateIni + "' "
    cQuery += " 	AND B3X_DATA < '" + cDateFim + "' "
    cQuery += " )  QTD "
	cQuery += " WHERE 1=1 "
    
    self:setQuery(self:queryBuilder(cQuery))
	If self:executaQuery()
        aMovQtd[1] := (self:getAliasTemp())->INCLUSAO
        aMovQtd[2] := (self:getAliasTemp())->RETIFICACAO
        aMovQtd[3] := (self:getAliasTemp())->MUDCONTRAT
        aMovQtd[4] := (self:getAliasTemp())->CANCELAMENTO
    EndIf
    self:fechaQuery()

return aMovQtd

