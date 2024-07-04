#include 'protheus.ch'
#include 'AGRA030.CH'
#include "fwmvcdef.ch"

/** {Protheus.doc} AGRA030
Rotina para cadastro de mão de obra

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	26/06/2018
@Uso: 		SIGAAGR
*/
Function AGRA030()
	Local oMBrowse := Nil
		
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("NNH")
	oMBrowse:SetDescription(STR0001) //"Cadastro de Tipo de Desconto"
	
	oMBrowse:Activate()

Return()


/*/{Protheus.doc} MenuDef
@author brunosilva
@since 06/12/2018
@version 1.0

@type function
/*/
Static Function MenuDef()
	Local aRotina := {}
	
	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "ViewDef.AGRA030", 0, 2, 0, Nil } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "ViewDef.AGRA030", 0, 3, 0, Nil } ) //"Incluir"
	aAdd( aRotina, { STR0005, "ViewDef.AGRA030", 0, 4, 0, Nil } ) //"Alterar"
	aAdd( aRotina, { STR0006, "ViewDef.AGRA030", 0, 5, 0, Nil } ) //"Excluir"

Return(aRotina)


/*/{Protheus.doc} ModelDef
@author brunosilva
@since 06/12/2018
@version 1.0

@type function
/*/
Static Function ModelDef()
	Local oStruNNH := FWFormStruct(1, "NNH")
	Local oModel   := MPFormModel():New("AGRA030")
	
	oModel:SetDescription(STR0001) 
	oModel:AddFields("NNHUNICO", Nil, oStruNNH)	
	oModel:GetModel("NNHUNICO"):SetDescription(STR0001) //"Cadastro de Tipo de Desconto"
	oModel:SetPrimaryKey({"NNH_FILIAL","NNH_CODIGO"})

Return(oModel)

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Equipe Agroindustria
@since: 	26/06/2018
@Uso: 		AGRA030 - Cadastro de Mão de Obra
*/
Static Function ViewDef()
	Local oStruNNH := FWFormStruct(2, "NNH")
	Local oModel   := FWLoadModel("AGRA030")
	Local oView    := FWFormView():New()
		
	oView:SetModel(oModel)
	oView:AddField("VIEW_NNH", oStruNNH, "NNHUNICO")
	
	oView:CreateHorizontalBox("UM", 100)
	oView:SetOwnerView("VIEW_NNH", "UM")
		
Return(oView)

/*{Protheus.doc} AGRA030VLD
Valiação do campo NNH_GRUPO
@author marcos.wagner
@since 21/11/2018
@version undefined
@param oField, object, descricao
@type function
*/
Function AGRA030VLD()

	If !ExistCpo('NNH',FwFldGet("NNH_GRUPO"))
		Return .f.
	EndIf

	If FwFldGet("NNH_GRUPO") == FwFldGet("NNH_CODIGO")
		MsgAlert(STR0007) //"O 'Grupo' deverá ser diferente do 'Codigo'."
		Return .f.
	EndIf

Return .t.
