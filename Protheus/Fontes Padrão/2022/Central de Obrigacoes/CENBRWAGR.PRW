#INCLUDE 'TOTVS.CH'

#DEFINE CAMPO   01
#DEFINE TIPO    02
#DEFINE TAMANHO 03
#DEFINE DECIMAL 04

Function CenBrwAgr(oTela)

	Local oBrw    := FWmBrowse():New()
	Private oTmpTab := nil
	Private cTabCrit := nil

	oTmpTab := oTela:getTabTemp()
	oTela:bscDados()
	oTela:loadTabTemp()
	oBrw:SetDescription( oTela:getTitulo() )
	oBrw:SetAlias( oTmpTab:getAlias() )
	oBrw:SetFields(oTela:getFields())
	oBrw:SetProfileID( oTela:getRotina() )
	oBrw:SetMenuDef(oTela:getRotina())
	oBrw:DisableDetails()
	oBrw:SetWalkthru(.F.)
	oBrw:SetAmbiente(.F.)
	If !IsBlind()
		oBrw:Activate()		
	EndIf
	oTela:destroy()
	FreeObj(oTela)
	oTela := nil

Return oBrw

Class CenBrwAgr
    Data cRotina
    Data cTitulo
    Data cWhere
    Data aCampos
    Data aFields
    Data cAliasTmp
    Data oTmpTab

    Method new() Constructor
    Method destroy()
    Method setRotina(cRotina)
    Method setTitulo(cTitulo)
    Method setWhere(cWhere)
    Method setCampos(aCampos)
    Method getRotina()
    Method getTitulo()
    Method getWhere()
	Method getQuery()
    Method getAliasTmp()
    Method bscDados()
    Method getTabTemp()
    Method makeTabTemp()
    Method loadTabTemp()
    Method getIndex()
    Method getCampos()
    Method getFields()
    Method X3Desc(cCampo)
    Method GetColuna(cCampo,cTitulo,cTipo,cPicture,nAlign,nSize,nDecimal)

EndClass

Method new() Class CenBrwAgr
    self:cRotina    := "CenCritAgr"
    self:cTitulo    := "Criticas Agrupadas"
    self:cWhere     := ""
    self:aCampos    := {}
    self:aFields    := {}
    self:cAliasTmp  := GetNextAlias()
    self:oTmpTab    := nil

Return self

Method destroy() Class CenBrwAgr
    If (Select(self:getAliasTmp()) <> 0)
        (self:getAliasTmp())->(dbCloseArea())
    EndIf
    If self:oTmpTab <> nil
        self:oTmpTab:delete()
        FreeObj(self:oTmpTab)
        self:oTmpTab := nil
    EndIf
Return

Method setRotina(cRotina) Class CenBrwAgr
    self:cRotina := cRotina
Return

Method setTitulo(cTitulo) Class CenBrwAgr
    self:cTitulo := cTitulo
Return

Method setWhere(cWhere) Class CenBrwAgr
    self:cWhere := cWhere
Return

Method setCampos(aCampos) Class CenBrwAgr
    self:aCampos := aCampos
Return

Method getRotina() Class CenBrwAgr
Return self:cRotina

Method getTitulo() Class CenBrwAgr
Return self:cTitulo

Method getWhere() Class CenBrwAgr
Return self:cWhere

Method getAliasTmp() Class CenBrwAgr
Return self:cAliasTmp

Method getQuery() Class CenBrwAgr
	Local cSql := ""
	cSql := " SELECT "
	cSql += "  COUNT(1) TOTAL,B3F_CODCRI,B3F_DESCRI "
	cSql += " FROM " 
	cSql += "   " + RetSqlName("B3F") + " B3F "
	cSql += " WHERE "
	cSQL += " B3F_FILIAL = '"+xFilial("B3F")+"' "
	cSQL += self:getWhere()
	cSQL += " AND B3F.D_E_L_E_T_ = ' '  "
	cSql += " GROUP BY B3F_CODCRI,B3F_DESCRI "
	cSql += " ORDER BY B3F_CODCRI,B3F_DESCRI "
Return cSql

Method bscDados() Class CenBrwAgr
    Local cSql 		:= self:getQuery()
	Local lFound	:= .F.

	cSql := ChangeQuery(cSql)
	conout(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),self:getAliasTmp(),.F.,.T.)

	lFound := !(self:getAliasTmp())->(Eof())
    
Return lFound

Method getTabTemp() Class CenBrwAgr
    If self:oTmpTab == nil
        self:makeTabTemp()
    EndIf
Return self:oTmpTab

Method makeTabTemp() Class CenBrwAgr
	Local nIndex := 0
    Local nLen  := 0
    Local aIndex := {}
    
    self:oTmpTab := FWTemporaryTable():New( GetNextAlias() )
	self:oTmpTab:SetFields( self:getCampos() )
	aIndex := self:getIndex()
    nLen := len(aIndex)
    For nIndex := 1 to nLen
        self:oTmpTab:AddIndex(aIndex[nIndex,1],aIndex[nIndex,2])
    Next nIndex
	self:oTmpTab:Create()
Return

Method loadTabTemp() Class CenBrwAgr
	Local lRet := .F.
	
	While !(self:getAliasTmp())->(Eof())

		RecLock(self:oTmpTab:getAlias(),.T.)
		(self:oTmpTab:getAlias())->TOTAL 		:= (self:getAliasTmp())->TOTAL
		(self:oTmpTab:getAlias())->B3F_CODCRI 	:= (self:getAliasTmp())->B3F_CODCRI
		(self:oTmpTab:getAlias())->B3F_DESCRI 	:= (self:getAliasTmp())->B3F_DESCRI
		(self:oTmpTab:getAlias())->(MsUnlock())
		(self:getAliasTmp())->(DbSkip())

	EndDo

	(self:getAliasTmp())->(dbCloseArea())
	lRet := .T.
Return lRet

Method getIndex() Class CenBrwAgr
    Local aIndex := {}
Return aIndex

Method getCampos() Class CenBrwAgr
Return self:aCampos

Method getFields() Class CenBrwAgr
    Local cPicture := "@!"
	Local nAlign   := 1 
    Local aCampos := self:getCampos()
	Local nCampo := 0
	Local nLen := len(aCampos)
    
    If len(self:aFields) == 0
        For nCampo := 1 to nLen
            aAdd(self:aFields,self:GetColuna(aCampos[nCampo,CAMPO] ,self:X3Desc(aCampos[nCampo,CAMPO] )  ,aCampos[nCampo,TIPO],cPicture,nAlign,aCampos[nCampo,TAMANHO],aCampos[nCampo,DECIMAL]))
        Next nCampo
    EndIf
Return self:aFields

Method X3Desc(cCampo) Class CenBrwAgr
	Local cDesc := "" 
	SX3->( dbSetOrder(2) )
	If SX3->( dbSeek( cCampo ) )
		cDesc := X3Descric()
	EndIf
Return cDesc

Method GetColuna(cCampo,cTitulo,cTipo,cPicture,nAlign,nSize,nDecimal) Class CenBrwAgr
	Local   aColuna  := {}
	Local   bData    := &("{||" + cCampo +"}") 
	Default nAlign   := 1
	Default nSize    := 20
	Default nDecimal := 0
	Default cTipo    := "C"
	
	aColuna := {cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return aColuna