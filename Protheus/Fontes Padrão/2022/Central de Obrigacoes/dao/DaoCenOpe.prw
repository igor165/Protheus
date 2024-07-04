#INCLUDE "TOTVS.CH"

#DEFINE SIB_INCLUIR  "1" // Incluir
#DEFINE SIB_RETIFIC  "2" // Retificar
#DEFINE SIB_MUDCONT  "3" // Mud.Contrat
#DEFINE SIB_CANCELA  "4" // Cancelar
#DEFINE SIB_REATIVA  "5" // Reativar

#DEFINE SINGLE  "01"
#DEFINE ALL     "02"
#DEFINE INSERT  "03"
#DEFINE DELETE  "04"
#DEFINE UPDATE  "05"
#DEFINE LOTE    "06"

Class DaoCenOpe from Dao
   
    Data cCodOpe
    Data cCnpjOp
    Data cRazSoc
    Data cNomFan
    Data cNatJur
    Data cModali
    Data cSegmen

    Data aMapBuilder
    Data oStatement

    Method New() Constructor

    Method setCodOpe(cCodOpe)
    Method setCnpjOp(cCnpjOp)
    Method setRazSoc(cRazSoc)
    Method setNomFan(cNomFan)
    Method setNatJur(cNatJur)
    Method setModali(cModali)
    Method setSegmen(cSegmen)

    Method getFields()
    Method getFilters()
    Method queryBuilder(cQuery)
    Method buscar(nType)

EndClass

Method New() Class DaoCenOpe
	_Super:New()
    self:aMapBuilder := {}
    self:oStatement :=  FWPreparedStatement():New()
Return self

Method getFields() Class DaoCenOpe

	If empty(self:cFields)
        self:cFields := "  B8M_CODOPE,	B8M_CNPJOP,	B8M_RAZSOC,	B8M_NOMFAN,	"
        self:cFields += "  B8M_NATJUR,	B8M_MODALI,	B8M_SEGMEN, "
        self:cFields += "  B8M.R_E_C_N_O_ RECNO "
    Endif
	 
Return self:cFields

Method buscar(nType) Class DaoCenOpe
	
    Local cQuery := ""
	Local lFound := .F.
    Local cAlias := "B8M"
    Default self:cfieldOrder := " B8M_CODOPE "
	
    if nType == SINGLE 
        cQuery += " SELECT "    
    Else
        cQuery += self:getRowControl(self:cfieldOrder, cAlias)
    Endif

    cQuery += self:getFields()
    cQuery += " FROM " + RetSqlName("B8M") + " B8M WHERE "
    cQuery += " B8M_FILIAL = '" + xFilial("B8M") + "' AND "
    cQuery += " B8M_CODOPE =  ?  AND "
    aAdd(self:aMapBuilder, self:cCodOpe)
   
    cQuery += " B8M.D_E_L_E_T_ 	= ? "
    aAdd(self:aMapBuilder, ' ')

    cQuery += self:getFilters()

    If nType == ALL
        cQuery += self:getWhereRow(cAlias)
    Endif

    cQuery := self:queryBuilder(cQuery)

    self:setQuery(cQuery)
    lFound := self:executaQuery()

    If lFound  /* .AND. (nType != ALL .OR. nType != INSERT)*/
		B8M->(DbGoto((self:getAliasTemp())->RECNO))
    EndIf

Return lFound

Method getFilters() Class DaoCenOpe

    Local filter := ""
    
Return filter

Method queryBuilder(cQuery) Class DaoCenOpe

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

Method setCodOpe(cCodOpe) Class DaoCenOpe
    self:cCodOpe := cCodOpe
Return 

Method setCnpjOp(cCnpjOp) Class DaoCenOpe
    self:cCnpjOp := cCnpjOp
Return 

Method setRazSoc(cRazSoc) Class DaoCenOpe
    self:cRazSoc := cRazSoc
Return 

Method setNomFan(cNomFan) Class DaoCenOpe
    self:cNomFan := cNomFan
Return 

Method setNatJur(cNatJur) Class DaoCenOpe
    self:cNatJur := cNatJur
Return 

Method setModali(cModali) Class DaoCenOpe
    self:cModali := cModali
Return 

Method setSegmen(cSegmen) Class DaoCenOpe
    self:cSegmen := cSegmen
Return 
