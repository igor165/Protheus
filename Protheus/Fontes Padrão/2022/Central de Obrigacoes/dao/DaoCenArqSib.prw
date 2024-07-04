#include "TOTVS.CH"

#DEFINE SINGLE "01"
#DEFINE ALL    "02"
#DEFINE INSERT "03"
#DEFINE DELETE "04"
#DEFINE UPDATE "05"
#DEFINE LOTE   "06"
#DEFINE BUSCA  "07"
#DEFINE CCOS   "CCOS"

Class DaoCenArqSib from Dao

    Data cCodOpe
    Data cAno
    Data cComp
    Data cArquiv
    Data cNomben
    Data cMatric
    Data cCodcco

    Data cB3R
    Data cB3X
    Data cB3K

    Method New() Constructor
    Method setCodOpe(cCodOpe)
    Method setAno(cAno)
    Method setArquiv(cArquiv)
    Method setComp(cComp)
    Method setNomben(cNomben)
    Method setMatric(cMatric)
    Method setCodcco(cCodcco)

    Method getFields()
    Method buscar(nType)
    Method bscCcos()

    Method commit(oCenArqSib, oRest, nType)
    Method loadOrder()
    Method getFilters()
    Method getCcoFilters()

EndClass

Method New() Class DaoCenArqSib
    _Super:New()
    self:loadOrder()
    self:cB3R := RetSqlName("B3R")
    self:cB3X := RetSqlName("B3X")
    self:cB3K := RetSqlName("B3K")
Return self

Method getFields() Class DaoCenArqSib

    If empty(self:cFields)
        self:cFields := " B3R_CODOPE, B3R_CDOBRI, B3R_ANO, B3R_CDCOMP, B3R_ARQUIV, B3R_SEQARQ,	"
        self:cFields += " R_E_C_N_O_ RECNO  "
    Endif

Return self:cFields

Method buscar(nType) Class DaoCenArqSib

    Local cQuery := ""
    Local lFound := .F.
    Local cAlias := "B3R"
    Default self:cfieldOrder := " B3R_CODOPE, B3R_ANO, B3R_ARQUIV "

    cQuery += self:getRowControl(self:cfieldOrder, cAlias)
    cQuery += self:getFields()

    cQuery += " FROM " + self:cB3R + " B3R WHERE "
    cQuery += " B3R_FILIAL = '" + xFilial("B3R") + "' AND "
    cQuery += " B3R.D_E_L_E_T_ 	= ' ' "

    cQuery += self:getFilters()
    cQuery += self:getWhereRow(cAlias)
    cQuery := self:queryBuilder(cQuery)

    self:setQuery(cQuery)
    lFound := self:executaQuery()

    If lFound .AND. (nType != ALL .OR. nType != INSERT)
        B3R->(DbGoto((self:cAliasTemp)->RECNO))
    EndIf

Return lFound

Method bscCcos() Class DaoCenArqSib

    Local cQuery := ""
    Local lFound := .F.
    Local oDaoCenBenefi := DaoCenBenefi():New()
    Local cAlias := "B3K"
    Default self:cfieldOrder := " B3K_CODOPE, B3K_CODCCO,  B3K_MATRIC "

    cQuery += self:getRowControl(self:cfieldOrder, cAlias)
    cQuery += oDaoCenBenefi:getFields()
    cQuery += " FROM " + self:cB3X + " B3X , " + self:cB3K + " B3K WHERE "
    cQuery += " B3X_FILIAL = '" + xFilial("B3X") + "' AND "
    cQuery += " B3K.R_E_C_N_O_ = B3X_BENEF AND "
    cQuery += " B3X_OPERA  =  ? AND "
    aAdd(self:aMapBuilder, '1')

    cQuery += " B3K_CODCCO <> ?  AND "
    aAdd(self:aMapBuilder, '')

    cQuery += " B3X_STATUS =  ? AND "
    aAdd(self:aMapBuilder, '6')

    cQuery += " B3K.D_E_L_E_T_  = ? "
    aAdd(self:aMapBuilder, ' ')

    cQuery += self:getCcoFilters()
    cQuery += self:getWhereRow(cAlias)
    cQuery := self:queryBuilder(cQuery)

    self:setQuery(cQuery)
    lFound := self:executaQuery()

Return lFound

Method loadOrder() Class DaoCenArqSib

    self:oHashOrder:set("FILENAME", "B3R.B3R_ARQUIV")
    self:oHashOrder:set("NAME", "B3K.B3K_NOMBEN")
    self:oHashOrder:set("SUBSCRIBERID", "B3K.B3K_MATRIC")
    self:oHashOrder:set("CODECCO", "B3K.B3K_CODCCO")

Return

Method getFilters() Class DaoCenArqSib

    Local filter := ""

    If !empty(self:cArquiv)
        filter += " AND B3R.B3R_ARQUIV = ? "
        aAdd(self:aMapBuilder, self:cAno + self:cArquiv)
    EndIf

    If !empty(self:cAno)
        filter += " AND B3R.B3R_ANO = ? "
        aAdd(self:aMapBuilder, self:cAno)
    EndIf

    If !empty(self:cComp)
        filter += " AND B3R.B3R_CDCOMP = ? "
        aAdd(self:aMapBuilder, self:cComp)
    EndIf

    If !empty(self:cCodOpe)
        filter += " AND B3R.B3R_CODOPE = ? "
        aAdd(self:aMapBuilder, self:cCodOpe)
    EndIf

Return filter

Method getCcoFilters() Class DaoCenArqSib

    Local filter := ""

    If !empty(self:cArquiv)
        filter += " AND B3X.B3X_ARQUIV = ? "
        aAdd(self:aMapBuilder, self:cArquiv)
    EndIf

    If !empty(self:cNomben)
        filter += " AND B3K.B3K_NOMBEN = ? "
        aAdd(self:aMapBuilder, self:cNomben)
    EndIf

    If !empty(self:cMatric)
        filter += " AND B3K.B3K_MATRIC = ? "
        aAdd(self:aMapBuilder, self:cMatric)
    EndIf

    If !empty(self:cCodcco)
        filter += " AND B3K.B3K_CODCCO = ? "
        aAdd(self:aMapBuilder, self:cCodcco)
    EndIf

Return filter

Method setCodOpe(cCodOpe) Class DaoCenArqSib
    self:cCodOpe := cCodOpe
Return

Method setAno(cAno) Class DaoCenArqSib
    self:cAno := cAno
Return

Method setArquiv(cArquiv) Class DaoCenArqSib
    self:cArquiv := cArquiv
Return

Method setComp(cComp) Class DaoCenArqSib
    self:cComp := cComp
Return

Method setNomben(cNomben) Class DaoCenArqSib
    self:cNomben := cNomben
Return

Method setMatric(cMatric) Class DaoCenArqSib
    self:cMatric := cMatric
Return

Method setCodcco(cCodcco) Class DaoCenArqSib
    self:cCodcco := cCodcco
Return
