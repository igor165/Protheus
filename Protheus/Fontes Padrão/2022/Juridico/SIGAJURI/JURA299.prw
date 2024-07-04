#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'JURA299.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA299
Aprovação de solicitações

@since 02/12/2021
/*/
//-------------------------------------------------------------------
Function JURA299()

Local oBrowse := FWMBrowse():New()

	oBrowse:SetDescription(STR0001) // Aprovação de solicitações
	oBrowse:SetAlias( "O1E" )
	oBrowse:Activate()
	oBrowse:Destroy()

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@since 02/12/2021
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := nil
Local oStrO1E   := FWFormStruct(1,'O1E')

	oModel := MPFormModel():New('JURA299', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('O1EMASTER',/*cOwner*/,oStrO1E,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:SetDescription(STR0001) // Aprovação de solicitações
	oModel:GetModel('O1EMASTER'):SetDescription(STR0001) //Aprovação de solicitações
	oModel:SetPrimaryKey( { "O1E_FILIAL", "O1E_CODIGO" } )

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@since 02/12/2021
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := FwLoadModel('JURA299')
Local oStrO1E := FWFormStruct(2, 'O1E')

	oView:SetModel(oModel)
	oView:AddField('VIEW_O1E' ,oStrO1E,'O1EMASTER')
	oView:SetDescription(STR0001) // Aprovação de solicitações

Return oView
