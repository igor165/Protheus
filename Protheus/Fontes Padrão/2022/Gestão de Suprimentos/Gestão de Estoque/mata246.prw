#INCLUDE 'Protheus.ch'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "MATA246.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} MATA246()
Movimentos Internos WMS

@author Bruno.Schmidt
@since  01/10/2015
@version 1.0
@return NIL
/*/
//-------------------------------------------------------------------
Function MATA246()
Local oBrowse:= FWMBrowse():New()

	oBrowse:SetAlias('DH1')
	oBrowse:SetDescription(STR0001)
	oBrowse:SetMenuDef('MATA246')
	oBrowse:SetFilterDefault( "DH1_STATUS=='1'" )
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Definição do Menu

@author Bruno.Schmidt
@since  01/10/2015
@version 1.0
@return aRotina
/*/
//-------------------------------------------------------------------	
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.MATA246' OPERATION 2 ACCESS 0 // Visualizar
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.MATA246' OPERATION 5 ACCESS 0 // Excluir

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Definicao do Modelo

@author Bruno.Schmidt
@since  01/10/2015
@version 1.0
@return oModel
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruDH1  := FWFormStruct( 1, 'DH1')
Local oModel    := Nil 
Local oWmsEvent := WMSModelEventMata246():New()

	//-- Cria a estrutura basica
	oModel := MPFormModel():New('MATA246', /*bPreValid*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	//-- Adiciona o componente de formulario no model 
	oModel:AddFields( 'DH1MASTER', /*cOwner*/  , oStruDH1)
	//-- Configura o model
	oModel:SetPrimaryKey( {} )
	oModel:SetDescription(STR0001) 
	oModel:GetModel( 'DH1MASTER' ):SetDescription(STR0001)
	oModel:InstallEvent("WMSM246", /*cOwner*/, oWmsEvent)

Return oModel

//--------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
Definicao da View

@author Bruno.Schmidt
@since  01/10/2015
@version 1.0
@return oView
/*/
//--------------------------------------------------------------------
Static Function ViewDef()
Local oModel   := FWLoadModel( 'MATA246' )
Local oStruDH1 := FWFormStruct( 2, 'DH1')

	oView := FWFormView():New()
	//-- Associa o View ao Model
	oView:SetModel( oModel )
	//-- Insere os componentes na view
	oView:AddField( 'VIEW_DH1', oStruDH1,'DH1MASTER' )
	//-- Cria os Box's
	oView:CreateHorizontalBox( 'CORPO',100)
	//-- Associa os componentes Cabecalho
	oView:SetOwnerView( 'VIEW_DH1' , 'CORPO')

Return oView
