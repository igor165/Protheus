#INCLUDE "TOTVS.CH"

#Define DBFIELD 1
#Define JSONFIELD 2

Class CenDaoB5Q from CenDao

    Method New(aFields) Constructor

    Method buscar()
    Method insert()
    Method commit()
    Method delete()    
    Method bscChaPrim()
    
EndClass

Method New(aFields) Class CenDaoB5Q
	_Super:New(aFields)
    self:cAlias := "B5Q"
    self:cfieldOrder := ""
Return self

Method buscar() Class CenDaoB5Q
	Local lFound := .F.
    lFound := _Super:buscar()
    If lFound 
		B5Q->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf
Return lFound

Method delete() Class CenDaoB5Q
    Local lFound := .F.
	if self:bscChaPrim()
        lFound := _Super:delete()    
    EndIf
Return lFound

Method bscChaPrim() Class CenDaoB5Q

    Local lFound := .F.
	Local cQuery := ""

    cQuery := " SELECT "
    cQuery += _Super:getFields()
    cQuery += " FROM " + RetSqlName('B5Q') + " "
	cQuery += " WHERE 1=1 "
	cQuery += " AND	B5Q_FILIAL = '" + xFilial("B5Q") + "' "
    
    cQuery += " AND	B5Q_DATA = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("errorDate")) )
    cQuery += " AND	B5Q_HORA = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("errorTime")) )
    cQuery += " AND	B5Q_IDREQU = ? "
    aAdd(self:aMapBuilder, self:toString(self:getValue("idRequest")) )
    cQuery += " AND D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    self:setQuery(self:queryBuilder(cQuery))
	lFound := self:executaQuery()

return lFound

Method insert() Class CenDaoB5Q
    Local lFound := !self:bscChaPrim()
	If lFound
        self:commit(.T.)
    EndIf
Return lFound

Method commit(lInclui) Class CenDaoB5Q

    Default lInclui := .F.

	If B5Q->(RecLock("B5Q",lInclui))
		
        B5Q->B5Q_FILIAL := xFilial("B5Q")
        B5Q->B5Q_DESCRI := _Super:normalizeType(B5Q->B5Q_DESCRI,self:getValue("errorDescription")) /* Column B5Q_DESCRI */
        B5Q->B5Q_DATA   := _Super:normalizeType(B5Q->B5Q_DATA  ,self:getValue("errorDate")) /* Column B5Q_DATA   */
        B5Q->B5Q_HORA   := _Super:normalizeType(B5Q->B5Q_HORA  ,self:getValue("errorTime")) /* Column B5Q_HORA   */
        B5Q->B5Q_IDREQU := _Super:normalizeType(B5Q->B5Q_IDREQU,self:getValue("idRequest")) /* Column B5Q_IDREQU */
        B5Q->B5Q_PATH   := _Super:normalizeType(B5Q->B5Q_PATH  ,self:getValue("path")) /* Column B5Q_PATH   */
        B5Q->B5Q_JSONIN := _Super:normalizeType(B5Q->B5Q_JSONIN,self:getValue("entradaJson")) /* Column B5Q_JSONIN */
        B5Q->B5Q_JSONOU := _Super:normalizeType(B5Q->B5Q_JSONOU,self:getValue("saidaJson")) /* Column B5Q_JSONOU */
        B5Q->B5Q_VERBO  := _Super:normalizeType(B5Q->B5Q_VERBO ,self:getValue("verboRequisicao")) /* Column B5Q_VERBO  */

        B5Q->(MsUnlock())
        lFound := .T.
    EndIf
Return lFound
