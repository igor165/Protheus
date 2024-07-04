#INCLUDE "TOTVS.CH"
#INCLUDE "VEIA020.CH"

Function VEIA020()
	Local oBrowse
	// Instanciamento da Classe de Browse
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('VVX')
	oBrowse:SetDescription(STR0001) // 'Cadastro de Segmento do Modelo'
	oBrowse:Activate()
Return

Static Function ModelDef()
	Local oStruVVX := FWFormStruct( 1, 'VVX' )
	Local oModel 

	oModel := MPFormModel():New('VEIA020' )
	oModel:AddFields( 'MODEL_VVX', /*cOwner*/, oStruVVX)
	oModel:SetDescription( STR0002 ) // 'Modelo de dados de Segmento do Modelo'
	oModel:GetModel( 'MODEL_VVX' ):SetDescription( STR0003 ) // 'Dados de Segmento do Modelo'
	
	oModel:SetPrimaryKey( { "VVX_FILIAL", "VVX_CODMAR", "VVX_SEGMOD" } )

Return oModel

Static Function ViewDef()

	Local oModel := FWLoadModel( 'VEIA020' )
	Local oStruVVX := FWFormStruct( 2, 'VVX' )
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_VVX', oStruVVX, 'MODEL_VVX' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_VVX', 'TELA' )

Return oView

Static Function MenuDef()
Return FWMVCMenu("VEIA020")