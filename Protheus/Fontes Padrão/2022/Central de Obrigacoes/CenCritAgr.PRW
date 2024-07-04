#INCLUDE 'TOTVS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE CAMPO   01
#DEFINE TIPO    02
#DEFINE TAMANHO 03
#DEFINE DECIMAL 04

Static Function MenuDef()

	Local aRotina := {}
	ADD OPTION aRotina Title 'Detalhar'  Action 'CenDetCriAgr(oTmpTab)'	OPERATION 2 ACCESS 0

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenCritAgr

@author everton.mateus
@since 22/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Function CenCritAgr()
	Local cWhere := ""
	Local oTela := CenCritAgr():New()

	oTela:setTitulo("Criticas Agrupadas")
	oTela:setRotina("CenCritAgr")
	cWhere := " AND B3F_CODOPE = '" + B3D->B3D_CODOPE + "'"
	cWhere += " AND B3F_CDOBRI = '" + B3D->B3D_CDOBRI + "'"
	cWhere += " AND B3F_ANO =  '" + B3D->B3D_ANO + "'"
	cWhere += " AND B3F_CDCOMP = '" + B3D->B3D_CODIGO + "'"
	If B3D->B3D_TIPOBR == '2'
		cWhere += " AND B3F_ORICRI = 'B3X' "
	EndIf
	oTela:setWhere(cWhere)

	CenBrwAgr(oTela)

Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenDetCriAgr


@author everton.mateus
@since 22/04/2019
/*/
//--------------------------------------------------------------------------------------------------
Function CenDetCriAgr(oTmpTab)

	Local oBrw := Nil
	Local cFiltro := " B3F_FILIAL = '" + xFilial( 'B3F' ) + "' .AND. " +;
			   " B3F_CODOPE = '" + B3D->B3D_CODOPE + "' .AND. " +;
			   " B3F_CDOBRI = '" + B3D->B3D_CDOBRI + "' .AND. " +;
			   " B3F_ANO = '" 	+ B3D->B3D_ANO + "' .AND. " +;
			   " B3F_CDCOMP = '" + B3D->B3D_CODIGO + "' .AND. " +;
			   " B3F_CODCRI = '" + (oTmpTab:getAlias())->B3F_CODCRI + "' "
	If B3D->B3D_TIPOBR == '2'
		cFIltro += " .AND. B3F_ORICRI = 'B3X' "
	EndIf	 

	If(!IsBlind())
		oBrw := PLBRWCrit(cFiltro, IsBlind())
	EndIf		

Return oBrw

Class CenCritAgr From CenBrwAgr
    
    Method new() Constructor
	Method getIndex()
	Method getCampos()
	Method getFields()

EndClass

Method new() Class CenCritAgr
   _Super:new()
Return self

Method getIndex() Class CenCritAgr
    Local aIndex := {}
    aAdd(aIndex, {"01",{"B3F_CODCRI"}} )
Return aIndex

Method getCampos() Class CenCritAgr
    if Len(self:aCampos) == 0
        aAdd(self:aCampos,{"TOTAL","N",010,0})
        aAdd(self:aCampos,{"B3F_CODCRI","C",4,0})
        aAdd(self:aCampos,{"B3F_DESCRI","C",100,0})
    EndIf
Return self:aCampos

Method getFields() Class CenCritAgr
    Local cPicture := "@!"
	Local nAlign   := 1 
    Local aCampos := self:getCampos()
	Local nCampo := 0
	Local nLen := len(aCampos)
    
    If len(self:aFields) == 0
        aAdd(self:aFields,self:GetColuna(aCampos[1,CAMPO] ,"Total",aCampos[1,TIPO],cPicture,nAlign,aCampos[1,TAMANHO],aCampos[1,DECIMAL]))
        For nCampo := 2 to nLen
            aAdd(self:aFields,self:GetColuna(aCampos[nCampo,CAMPO] ,self:X3Desc(aCampos[nCampo,CAMPO] )  ,aCampos[nCampo,TIPO],cPicture,nAlign,aCampos[nCampo,TAMANHO],aCampos[nCampo,DECIMAL]))
        Next nCampo
    EndIf
Return self:aFields