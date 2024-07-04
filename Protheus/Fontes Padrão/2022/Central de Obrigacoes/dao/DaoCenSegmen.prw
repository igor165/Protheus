#include "TOTVS.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"

Class DaoCenSegmen from Dao

    Data cSegmen
    Data cB4y

    Method New() Constructor
    Method setSegmen(cSegmen)
    
    Method getFields()
    Method buscar(nType)
    Method commit(oCenSegmen, oRest, nType)

EndClass

Method New() Class DaoCenSegmen
	_Super:New()
    self:cB4Y := RetSqlName("B4Y")
Return self

Method getFields() Class DaoCenSegmen

	if empty(self:cFields)
        self:cFields := " B4Y_SEGMEN,	B4Y_DESORI,	B4Y_PERDES,	"
        self:cFields += " R_E_C_N_O_ RECNO  "
    endif
	
Return self:cFields

Method buscar(nType) Class DaoCenSegmen
	
    Local cQuery := ""
	Local lFound := .F.
    Local cAlias := "B4Y"
    Default self:cfieldOrder  := " B4Y_SEGMEN "
	
    if nType == SINGLE 
        cQuery += " SELECT "    
    Else
        cQuery += self:getRowControl(self:cfieldOrder, cAlias)
    Endif

    cQuery += self:getFields()
	
    cQuery += " FROM " + self:cB4Y + " B4Y WHERE "
	cQuery += " B4Y_FILIAL = '" + xFilial("B4Y") + "' AND "
    cQuery += " B4Y_SEGMEN = '" + self:cSegmen + "' AND "
    cQuery += " B4Y.D_E_L_E_T_ 	= ' ' "

    If nType == ALL
        cQuery += self:getWhereRow(cAlias)
    Endif

    self:setQuery(cQuery)
    lFound := self:executaQuery()

    If lFound
	    B4Y->(DbGoto((self:cAliasTemp)->RECNO))
    EndIf

Return lFound

Method commit(oCenSegmen, oRest, nType) Class DaoCenSegmen
    
    Local lRet := .F.
    Local lExiste := nil

    lExiste := self:buscar(SINGLE)

    If oRest:lSuccess
        Reclock("B4Y", !lExiste)

            B4Y->B4Y_FILIAL := xFilial("B4Y")

            If oCenSegmen:getSegmen() != nil 
                B4Y->B4Y_SEGMEN := oCenSegmen:getSegmen()
            EndIf
            If oCenSegmen:getDesOri() != nil 
                B4Y->B4Y_DESORI := oCenSegmen:getDesOri()
            EndIf
            If oCenSegmen:getPerDes() != nil 
                B4Y->B4Y_PERDES := oCenSegmen:getPerDes()
            EndIf
        B4Y->(MsUnlock())
        lRet := .T.
    EndIf    

Return lRet

Method setSegmen(cSegmen) Class DaoCenSegmen
    self:cSegmen := cSegmen
Return