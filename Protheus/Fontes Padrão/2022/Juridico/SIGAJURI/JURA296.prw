#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'JURA296.ch'

/*
	Modelo de dados para o cadastro de Tipos de atos societários
*/

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@since 10/09/2021
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel    := nil
Local oStrO1C   := FWFormStruct(1,'O1C')

	oModel := MPFormModel():New('JURA296', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )
	oModel:AddFields('O1CMASTER',/*cOwner*/,oStrO1C,/*bPre*/,/*bPos*/,/*bLoad*/)
	oModel:SetDescription(STR0001)// 'Tipo de ato societário'
	oModel:GetModel('O1CMASTER'):SetDescription(STR0001) //'Tipo de ato societário' 

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author 
@since 13/09/2021
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView   := FWFormView():New()
Local oModel  := FwLoadModel('JURA296')
Local oStrO1C := FWFormStruct(2, 'O1C')

	oView:SetModel(oModel)
	oView:AddField('VIEW_O1C' ,oStrO1C,'O1CMASTER')
	oView:SetDescription(STR0001) //'Tipo de ato societário'

Return oView
