#Include "Protheus.ch"
#Include "FwMvcDef.ch"
#Include "TopConn.ch"
#INCLUDE "FWBROWSE.CH"

/*/{Protheus.doc} CENPOBHA

Tela MVC para apresentação dos registros  e execução de rotinas
referentes à tabela BHA - Artefatos da Central

@author p.drivas
@since 14/05/2020
/*/

Function CENPOBHA()

  Local aCoors    := FWGetDialogSize( oMainWnd )
	Local oFWLayer	:= FWLayer():New()
	Local cDescript := "Artefatos Central" 
  Local oPnl
	Local oBrowse
	Local cAlias	:= "BHA"
	Local lAutom := .F.
	
  Private oDlgBHA
	Private aRotina	:= {}

	Default cFiltro	:= 	""

  (cAlias)->(dbSetOrder(1))

	If !lAutom
		Define MsDialog oDlgBHA Title cDescript From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer:Init( oDlgBHA, .F., .T. )
		oFWLayer:AddLine( 'LINE', 100, .F. )
		oFWLayer:AddCollumn( 'COL', 100, .T., 'LINE' )
		oPnl := oFWLayer:GetColPanel( 'COL', 'LINE' )
	EndIf

	oBrowse:= FWMBrowse():New()
	oBrowse:SetOwner( oPnl )
	oBrowse:SetFilterDefault( cFiltro )
	oBrowse:SetDescription( cDescript )
	oBrowse:SetAlias( cAlias )
	
	oBrowse:SetMenuDef( 'CENPOBHA' )
	oBrowse:SetProfileID( 'CENPOBHA' )
	oBrowse:ForceQuitButton()
	oBrowse:DisableDetails()

	If !lAutom
		oBrowse:Activate(/*oPnl*/)
		Activate MsDialog oDlgBHA Centered
	EndIf

Return oBrowse
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Defininao das opcoes do menu

@author p.drivas
@since 14/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function MenuDef()
	Private aRotina	:= {}
	aAdd( aRotina, { "Visualizar"      , 'VIEWDEF.CENPOBHA' , 0 , 2 , 0 , NIL } )
	aAdd( aRotina, { "Atualizar"       , ""                  , 0 , 4 , 0 , NIL } )
	aAdd( aRotina, { "Verificar"       , ""                  , 0 , 4 , 0 , NIL } )
	aAdd( aRotina, { "Atualizar Todos" , ""                  , 0 , 4 , 0 , NIL } )
Return aRotina
//-------- , NIL ------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Definicao do modelo MVC para a tabela BHA

@return oModel	objeto model criado

@author p.drivas
@since 14/05/2020
/*/
//--------------------------------------------------------------------------------------------------
Static Function ModelDef()
	Local oStruBHA 	:= FWFormStruct( 1, 'BHA', , )
	Local oModel		:= Nil
	
	oModel := MPFormModel():New( "Ocorrências por Guia", /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields( 'BHAMASTER', NIL , oStruBHA )
	oModel:GetModel( 'BHAMASTER' ):SetDescription( "Ocorrências Gerais" )
	oModel:SetPrimaryKey({"BHA_FILIAL","BHA_COD"})

Return oModel
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Definicao da visao MVC para a tabela BHA

@return oView	objeto view criado

@author p.drivas
@since 14/05/2020
/*/
//--------------------------------------------------------------------------------------------------

Static Function ViewDef()
	Local oModel   := FWLoadModel( 'CENPOBHA' )
	Local oStruBHA := FWFormStruct( 2, 'BHA' )
	Local oView    := FWFormView():New()

	oView:SetModel( oModel )
	oView:AddField( 'VIEW_BHA' , oStruBHA , 'BHAMASTER' )
	oView:CreateHorizontalBox( 'SUPERIOR', 100 )
	oView:SetOwnerView( 'VIEW_BHA', 'SUPERIOR' )
	oView:EnableTitleView( 'VIEW_BHA', 'Ocorrências Gerais' )

Return oView