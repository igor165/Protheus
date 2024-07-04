#include "TOTVS.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"

Class DaoCenAbrang from Dao

    Data cCodOri
    Data cB4x

    Method New() Constructor
    Method setCodOri(cCodOri)
    Method getFields()
    Method buscar(nType)
    Method commit(oCenAbrang, oRest, nType)

EndClass

Method New() Class DaoCenAbrang
	_Super:New()
    self:cB4X := RetSqlName("B4X")
Return self

Method getFields() Class DaoCenAbrang

	If empty(self:cFields)
        self:cFields := " B4X_CODORI,	B4X_DESORI,	B4X_PERDES,	"
        self:cFields += " R_E_C_N_O_ RECNO  "
    Endif
	
Return self:cFields

Method buscar(nType) Class DaoCenAbrang
	
    Local cQuery := ""
	Local lFound := .F.
    Local cAlias := "B4X"
    Default self:cfieldOrder  := " B4X_CODORI "
	
    if nType == SINGLE 
        cQuery += " SELECT "    
    Else
        cQuery += self:getRowControl(self:cfieldOrder, cAlias)
    Endif

    cQuery += self:getFields()
	
    cQuery += " FROM " + self:cB4X + " B4X WHERE "
	cQuery += " B4X_FILIAL = '" + xFilial("B4X") + "' AND "
    cQuery += " B4X_CODORI = '" + self:cCodOri + "' AND "
    cQuery += " B4X.D_E_L_E_T_ 	= ' ' "

    If nType == ALL
        cQuery += self:getWhereRow(cAlias)
    Endif

    self:setQuery(cQuery)
    lFound := self:executaQuery()

    If lFound
	    B4X->(DbGoto((self:cAliasTemp)->RECNO))
    EndIf

Return lFound

Method commit(oCenAbrang, oRest, nType) Class DaoCenAbrang
    
    Local lRet := .F.
    Local lExiste := nil

    lExiste := self:buscar(SINGLE)

    If oRest:lSuccess
        Reclock("B4X", !lExiste)

            B4X->B4X_FILIAL := xFilial("B4X")

            If oCenAbrang:getCodOri() != nil
                B4X->B4X_CODORI	:= oCenAbrang:getCodOri()
            EndIf
            If oCenAbrang:getDesOri() != nil
                B4X->B4X_DESORI	:= oCenAbrang:getDesOri()
            EndIf
            If oCenAbrang:getPerDes() != nil
                B4X->B4X_PERDES:= oCenAbrang:getPerDes()
            EndIf
            
        B4X->(MsUnlock())
        lRet := .T.
    EndIf    

Return lRet

Method setCodOri(cCodOri) Class DaoCenAbrang
    self:cCodOri := cCodOri
Return
