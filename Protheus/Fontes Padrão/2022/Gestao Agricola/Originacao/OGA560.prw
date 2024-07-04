#include "protheus.ch"
#include "fwmvcdef.ch"
#include "oga560.ch"

/*{Protheus.doc} OGA560
//Cadastro de finalidades.
@author roney.maia
@since 11/10/2017
@version 1.0
@type function
*/
Function OGA560()

	Local oMBrowse	:= Nil
		
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("N8A")
	oMBrowse:SetMenuDef("OGA560")
	oMBrowse:SetDescription(STR0001) // # Finalidades
	oMBrowse:DisableDetails()
	oMBrowse:Activate()

Return

/*{Protheus.doc} MenuDef
// Menus do browse.
@author roney.maia
@since 11/10/2017
@version 1.0
@return ${return}, ${Array de Menus}
@type function
*/
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd( aRotina, {STR0002, "PesqBrw"       , 0, 1, 0, .T. } ) // # Pesquisar
	aAdd( aRotina, {STR0003, "ViewDef.OGA560", 0, 2, 0, 	} ) // # Visualizar
	aAdd( aRotina, {STR0004, "ViewDef.OGA560", 0, 3, 0,     } ) // # Incluir
	aAdd( aRotina, {STR0005, "ViewDef.OGA560", 0, 4, 0,     } ) // # Alterar
	aAdd( aRotina, {STR0006, "ViewDef.OGA560", 0, 5, 0,     } ) // # Excluir
	aAdd( aRotina, {STR0007, "ViewDef.OGA560", 0, 8, 0,     } ) // # Imprimir
	aAdd( aRotina, {STR0008, "ViewDef.OGA560", 0, 9, 0,     } ) // # Copiar

Return aRotina

/*{Protheus.doc} ModelDef
// Função responsável por construir o modelo da rotina.
@author roney.maia
@since 11/10/2017
@version 1.0
@return ${return}, ${Objeto modelo da rotina}
@type function
*/
Static Function ModelDef()

	Local oStruN8A := FWFormStruct(1, "N8A")
	Local oStruNLM := FWFormStruct(1, "NLM")
	
	Local oModel := MPFormModel():New("OGA560")
	
	oModel:AddFields("N8AUNICO", , oStruN8A)
	oModel:SetDescription(STR0001) // # Finalidades
	oModel:GetModel("N8AUNICO"):SetDescription(STR0001) // # Finalidades
	
	If TableInDic("NLM") 
		oModel:AddGrid("NLMUNICO", "N8AUNICO", oStruNLM)
		oModel:GetModel("NLMUNICO"):SetUniqueLine({"NLM_SEQUEN"})
		oModel:GetModel("NLMUNICO"):SetOptional(.T.)
		oModel:SetRelation("NLMUNICO", {{"NLM_FILIAL", "xFilial('NLM')"}, {"NLM_FINALI", "N8A_CODIGO"}}, NLM->(IndexKey(1)))
		oModel:GetModel("NLMUNICO"):SetDescription(STR0009) // # Operações Fiscais
	EndIf
		
Return oModel
	
/*{Protheus.doc} ViewDef
// Função responsável por construir a view da rotina.
@author roney.maia
@since 11/10/2017
@version 1.0
@return ${return}, ${Objeto view da rotina}
@type function
*/
Static Function ViewDef()

	Local oModel   := FWLoadModel( "OGA560" )
	Local oView    := FWFormView():New()

	Local oStruN8A := FWFormStruct(2, "N8A")
	Local oStruNLM := FWFormStruct(2, "NLM")
	
	If TableInDic("NLM") 
		oStruNLM:RemoveField("NLM_FINALI")
	EndIF

	oView:SetModel(oModel)
	oView:AddField("VIEW_N8A", oStruN8A, "N8AUNICO")
	If TableInDic("NLM") 
		oView:AddGrid( "VIEW_NLM", oStruNLM, "NLMUNICO")
	EndIf
	
	oView:CreateVerticallBox("BOXHEADER", 100)
	
	oView:CreateHorizontalBox("SUPERIOR" , 30, "BOXHEADER")
	oView:CreateHorizontalBox("INFERIOR" , 70, "BOXHEADER")
	
	oView:SetOwnerView("VIEW_N8A", "SUPERIOR")

	If TableInDic("NLM") 
		oView:SetOwnerView("VIEW_NLM", "INFERIOR")
	EndIf
	
	oView:EnableTitleView( "VIEW_N8A")

	If TableInDic("NLM") 
		oView:EnableTitleView( "VIEW_NLM")
		oView:AddIncrementField("VIEW_NLM", "NLM_SEQUEN")
	EndIf
	
Return oView