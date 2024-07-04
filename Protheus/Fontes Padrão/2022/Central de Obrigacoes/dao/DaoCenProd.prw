#include "TOTVS.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE LOTE   "06"
#DEFINE BUSCA  "07"

Class DaoCenProd from Dao

    Data cCodigo
    Data cCodope
    Data cDescri
    Data cForcon
    Data cSegmen
    Data cAbrang
    Data cB3j

    Method New() Constructor
    Method setCodigo(cCodigo)
    Method setCodope(cCodope)
    Method setDescri(cDescri)
    Method setForcon(cForcon)
    Method setSegmen(cSegmen)
    Method setAbrang(cAbrang)

    Method getFields()
    Method getFilters()
    Method buscar(nType)
    Method loadOrder() 

    Method commit(oCenProd, oRest, nType)

EndClass

Method New() Class DaoCenProd
	_Super:New()
    self:loadOrder()
    self:cB3j := RetSqlName("B3J")
Return self

Method getFields() Class DaoCenProd

	if empty(self:cFields)
        self:cFields := " B3J_CODOPE, B3J_CODIGO, B3J_DESCRI, B3J_FORCON, "
        self:cFields += " B3J_SEGMEN, B3J_STATUS, B3J_DTINVL, B3J_HRINVL, "
        self:cFields += " B3J_DTTEVL, B3J_HRTEVL, B3J_ABRANG, "
        self:cFields += " R_E_C_N_O_ RECNO "
    endif
	
Return self:cFields

Method buscar(nType) Class DaoCenProd
	
    Local cQuery := ""
	Local lFound := .F.
    Local cAlias := "B3J"
    Default self:cCodOpe := ""
    Default self:cCodigo := ""
    Default self:cfieldOrder  := " B3J_CODOPE,  B3J_CODIGO "
    
    cQuery += self:getRowControl(self:cfieldOrder, cAlias)
	cQuery += self:getFields()
	
    cQuery += " FROM " + self:cB3j + " B3J WHERE "
	cQuery += " B3J_FILIAL = '" + xFilial("B3J") + "' AND "
    cQuery += " B3J_CODOPE = ? "
    aAdd(self:aMapBuilder, self:cCodOpe)

    
    cQuery += "AND B3J.D_E_L_E_T_ = ? "
    aAdd(self:aMapBuilder, ' ')
    
    cQuery += self:getFilters()    
    cQuery += self:getWhereRow(cAlias)
    cQuery := self:queryBuilder(cQuery)

	self:setQuery(cQuery)
    lFound := self:executaQuery()

    If lFound .AND. (nType != ALL .OR. nType != INSERT)
	    B3J->(DbGoto((self:cAliasTemp)->RECNO))
    EndIf

Return lFound

Method commit(oCenProd, oRest, nType) Class DaoCenProd
    
    Local lRet := .T.
    Local lExiste := nil

    lExiste := oRest:buscar(nType)
    lRet := oRest:lSuccess

    If oRest:lSuccess
        If nType == DELETE
            B3J->(recLock("B3J",.F.))
		        B3J->(DbDelete())
	        B3J->(msUnLock())
        Else    
            Reclock("B3J", !lExiste)
                B3J->B3J_FILIAL := xFilial("B3J")
                B3J->B3J_CODOPE := oCenProd:getCodOpe()	
                B3J->B3J_CODIGO := oCenProd:getCodigo()
                if oCenProd:getDescri() != nil
                    B3J->B3J_DESCRI := oCenProd:getDescri()
                EndIf
                if oCenProd:getForCon() != nil
                    B3J->B3J_FORCON := oCenProd:getForCon()
                EndIf
                if oCenProd:getSegmen() != nil
                    B3J->B3J_SEGMEN := oCenProd:getSegmen()
                EndIf                                    
                if oCenProd:getSegmen() != nil
                    B3J->B3J_SEGMEN := oCenProd:getSegmen()
                EndIf                                    
                if oCenProd:getAbrang() != nil
                    B3J->B3J_ABRANG := oCenProd:getAbrang()
                EndIf
                B3J->B3J_STATUS := "1"
            B3J->(MsUnlock())
        Endif
    EndIf    

Return lRet

Method getFilters() Class DaoCenProd

    Local filter := ""
        
    If !empty(self:cCodigo)
        filter += " AND B3J_CODIGO  = ? "
        aAdd(self:aMapBuilder, self:cCodigo)
    EndIf
    If !empty(self:cCodope)
        filter += " AND B3J_CODOPE  = ? "
        aAdd(self:aMapBuilder, self:cCodope)
    EndIf
    If !empty(self:cDescri)
        filter += " AND B3J_DESCRI  = ? "
        aAdd(self:aMapBuilder, self:cDescri)
    EndIf
    If !empty(self:cForcon)
        filter += " AND B3J_FORCON  = ? "
        aAdd(self:aMapBuilder, self:cForcon)
    EndIf
    If !empty(self:cSegmen)
        filter += " AND B3J_SEGMEN  = ? "
        aAdd(self:aMapBuilder, self:cSegmen)
    EndIf
    If !empty(self:cAbrang)
        filter += " AND B3J_ABRANG  = ? "
        aAdd(self:aMapBuilder, self:cAbrang)
    EndIf
    
Return filter

Method loadOrder() Class DaoCenProd

    self:oHashOrder:set("CODE", "B3J_CODIGO")
    self:oHashOrder:set("HEALTHINSURERCODE", "B3J_CODOPE")
    self:oHashOrder:set("DESCRIPTION", "B3J_DESCRI")
    self:oHashOrder:set("WAYOFHIRING", "B3J_FORCON")
    self:oHashOrder:set("MARKETSEGMENTATION", "B3J_SEGMEN")
    self:oHashOrder:set("COVERAGEAREA", "B3J_ABRANG")

Return

Method setCodigo(cCodigo) Class DaoCenProd
    self:cCodigo := cCodigo
Return
Method setCodope(cCodope) Class DaoCenProd
    self:cCodope := cCodope
Return
Method setDescri(cDescri) Class DaoCenProd
    self:cDescri := cDescri
Return
Method setForcon(cForcon) Class DaoCenProd
    self:cForcon := cForcon
Return
Method setSegmen(cSegmen) Class DaoCenProd
    self:cSegmen := cSegmen
Return
Method setAbrang(cAbrang) Class DaoCenProd
    self:cAbrang := cAbrang
Return
