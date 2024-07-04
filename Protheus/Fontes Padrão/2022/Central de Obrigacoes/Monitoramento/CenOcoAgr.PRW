#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

#DEFINE PB5PTOTAL	01
#DEFINE PB5PCODIGO	02
#DEFINE PB5PDESERR	03
#DEFINE CAMPO   01
#DEFINE TIPO    02
#DEFINE TAMANHO 03
#DEFINE DECIMAL 04

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Definição das opções do menu

@author jose.paulo
@since 11/02/20

/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	aAdd( aRotina, { "Detalhar"       , "CenDetOcoAgr(.F.)"               , 0 , 2 , 0 , NIL } )

Return aRotina

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenOcoAgr

Exibe um browse com as ocorrências agrupadas por código e descrição

@author jose.paulo
@since 11/02/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CenOcoAgr(lAuto,cAlias)

	Local aCampos := RetornaCampos()
	Local oTmpTab := CriaTabTemp(aCampos)
	Private oBrwOco := FWmBrowse():New()
	Default lAuto := .F.
	Default cAlias := "B5P"
	
	oBrwOco:SetDescription( "Ocorrências Agrupadas" )
	oBrwOco:SetAlias( oTmpTab:getAlias() )
	oBrwOco:SetFields(montaFields(aCampos))
	oBrwOco:SetProfileID( 'CenOcoAgr' )
	oBrwOco:SetMenuDef('CenOcoAgr')
	oBrwOco:DisableDetails()
	oBrwOco:SetWalkthru(.F.)
	oBrwOco:SetAmbiente(.F.)
	If BscOcorren(cAlias)
		CarregaArqTmp() 
	EndIf
	If !lAuto
		oBrwOco:Activate()		
	EndIf

	oTmpTab:delete()

Return oBrwOco

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CenDetOcoAgr

Exibe um browse com as o detalhes da ocorrência selecionada

@author jose.paulo
@since 11/02/2020
/*/
//--------------------------------------------------------------------------------------------------
Function CenDetOcoAgr(lAuto)

	Local oBrw := Nil
	Local cFiltro := getBrwFilt()
	
	Default lAuto := .F.

	If(!lAuto)
		oBrw := PLBRWOCO(cFiltro, lAuto)
	EndIf		

Return oBrw

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetornaCampos

Retorna os campos para criar o arquivo temporario 

@author jose.paulo
@since 11/02/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetornaCampos()

	Local aCampos := {}
	
	aAdd(aCampos,{"TOTAL"		,"N",010,0})
	aAdd(aCampos,{"B5P_CDCMER"	,"C",004,0})
	aAdd(aCampos,{"B5P_DESERR"	,"C",100,0})
	aAdd(aCampos,{"ALIAS"		,"C",3,0})
	
Return aCampos

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CriaTabTemp

Cria o arquivo temporario de vencimentos

@author jose.paulo
@since 11/02/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function CriaTabTemp(aCampos)

	Local oTmpTab   := Nil
	Default aCampos := {}

	oTmpTab := FWTemporaryTable():New( 'GRPB5P' )
	oTmpTab:SetFields( aCampos )
	oTmpTab:AddIndex("01",{"B5P_CDCMER"})
	oTmpTab:AddIndex("02",{"TOTAL"})
	oTmpTab:Create()

Return oTmpTab

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} BscOcorren

Busca os compromissos a vencer

@author jose.paulo
@since 11/02/20
/*/
//--------------------------------------------------------------------------------------------------
Function BscOcorren(cAlias)

	Local cAliasTmp := "TRBB5P"
	Local cSql 		:= ""
	Local lFound	:= .F.

	cSql := " SELECT COUNT(1) TOTAL,B5P_CDCMER,B5P_DESERR, '"+cAlias+"' ALIAS "
	cSql += " FROM " 
	cSql += "   " + RetSqlName("B5P") + " B5P "
	cSql += " WHERE B5P_FILIAL = '"+xFilial("B5P")+"' "
	cSql += getQryFilt(cAlias)
	cSql += " AND B5P.D_E_L_E_T_ = ''  "
	cSql += " GROUP BY B5P_CDCMER,B5P_DESERR "
	cSql += " ORDER BY B5P_CDCMER,B5P_DESERR "

	If (Select('TRBB5P') <> 0)
		TRBB5P->(dbCloseArea())
	EndIf

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cAliasTmp,.F.,.T.)

	lFound := !TRBB5P->(Eof())
	If !lFound
		TRBB5P->(dbCloseArea())
	EndIf

Return lFound

Static Function getQryFilt(cAlias)
	Local cSql := ""
	If cAlias == "B5P"
		cSQL += " AND B5P_CODOPE = '" + B5P->B5P_CODOPE + "'"
		cSQL += " AND B5P_CMPLOT = '" + B5P->B5P_CMPLOT + "'"
		cSQL += " AND B5P_NUMLOT = '" + B5P->B5P_NUMLOT + "'"
	EndIf

Return cSql

Static Function getBrwFilt()
	Local cFiltro := ""
	Local cAlias := (oBrwOco:getAlias())->ALIAS
	If cAlias == "B5P"
		cFiltro += " B5P_FILIAL = '" + xFilial( 'B5P' )     + "' .AND. "
		cFiltro += " B5P_CODOPE = '" + B5P->B5P_CODOPE      + "' .AND. "
		cFiltro += " B5P_CMPLOT = '" + B5P->B5P_CMPLOT      + "' .AND. "
		cFiltro += " B5P_NUMLOT= '"  + B5P->B5P_NUMLOT      + "' .AND. "
		cFiltro += " B5P_CDCMER = '" + (oBrwOco:getAlias())->B5P_CDCMER+ "' "
	EndIf

Return cFiltro

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CarregaArqTmp

Preenche o arquivo temporario com as ocorrências

@author jose.paulo
@since 11/02/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function CarregaArqTmp(oTmpTab)

	Local lRet := .F.
	
	While !TRBB5P->(Eof())

		RecLock('GRPB5P',.T.)
		GRPB5P->TOTAL 		:= TRBB5P->TOTAL
		GRPB5P->B5P_CDCMER 	:= TRBB5P->B5P_CDCMER
		GRPB5P->B5P_DESERR 	:= TRBB5P->B5P_DESERR
		GRPB5P->ALIAS 		:= TRBB5P->ALIAS
		GRPB5P->(MsUnlock())
		TRBB5P->(DbSkip())

	EndDo

	TRBB5P->(dbCloseArea())
	lRet := .T.

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} montaFields

Carrega os campos do browse de vencimentos 

@author jose.paulo
@since 11/02/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function montaFields(aCampos)

	Local cPicture := "@!"
	Local nAlign   := 1 
	Local aFields  := {}

	aAdd(aFields,GetColuna(aCampos[PB5PTOTAL,CAMPO] ,"  Total    "     ,aCampos[PB5PTOTAL,TIPO],cPicture,nAlign,aCampos[PB5PTOTAL,TAMANHO],aCampos[PB5PTOTAL,DECIMAL]))
	aAdd(aFields,GetColuna(aCampos[PB5PCODIGO,CAMPO],"  Codigo   "    ,aCampos[PB5PCODIGO,TIPO],cPicture,nAlign,aCampos[PB5PCODIGO,TAMANHO],aCampos[PB5PCODIGO,DECIMAL]))
	aAdd(aFields,GetColuna(aCampos[PB5PDESERR,CAMPO]," Descrição " ,aCampos[PB5PDESERR,TIPO],cPicture,nAlign,aCampos[PB5PDESERR,TAMANHO],aCampos[PB5PDESERR,DECIMAL]))
	
Return aFields 

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetColuna

Retorna uma coluna para o markbrowse 

@author jose.paulo
@since 11/02/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function GetColuna(cCampo,cTitulo,cTipo,cPicture,nAlign,nSize,nDecimal)

	Local   aColuna  := {}
	Local   bData    := &("{||" + cCampo +"}") 
	Default nAlign   := 1
	Default nSize    := 20
	Default nDecimal := 0
	Default cTipo    := "C"
	
	aColuna := {cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.F.,{||.T.},.F.,{||.T.},NIL,{||.T.},.F.,.F.,{}}

Return aColuna

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLBRWOCO

Tela que exibe as ocorrências

@author jose.paulo
@since 11/02/20
/*/
//--------------------------------------------------------------------------------------------------
Function PLBRWOCO(cFiltro, lAuto)

	Local aCoors := FWGetDialogSize( oMainWnd )
	Local oFWLayer
	Local oPnl
	Local oBrowse
	Private oDlgPrinc

	Default cFiltro := ""
	Default lAuto := .F.

	Define MsDialog oDlgPrinc Title 'Ocorrências' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

	oFWLayer:AddLine( 'LINE', 100, .F. )
	oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
	oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )

	oBrowse := FWmBrowse():New()
	oBrowse:SetOwner( oPnl )
	
	oBrowse:SetDescription( "Ocorrências" )
	oBrowse:SetAlias( 'B5P' )
	oBrowse:SetMenuDef( 'CENMVCB5P' )
	oBrowse:SetProfileID( 'CENMVCB5P' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()
	oBrowse:SetWalkthru(.F.)
	oBrowse:SetAmbiente(.F.)
	
	If !Empty(cFiltro)
		oBrowse:SetFilterDefault(cFiltro)
	EndIf

	oBrowse:Activate()

	If !lAuto
		Activate MsDialog oDlgPrinc Center
	EndIf

Return oBrowse