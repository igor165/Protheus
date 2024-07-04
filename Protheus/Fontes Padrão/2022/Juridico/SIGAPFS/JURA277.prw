#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "JURA277.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA277
Modelo de Itens de Projeto

@author Willian Kazahaya
@since  10/07/2020
/*/
//-------------------------------------------------------------------
Function JURA277()
	Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetDescription(STR0001) //"Item de Projeto"
	oBrowse:SetAlias("OHM")
	oBrowse:SetLocate()
	oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura do menu
        [n,1] Nome a aparecer no cabecalho
        [n,2] Nome da Rotina associada
        [n,3] Reservado
        [n,4] Tipo de Transação a ser efetuada:
            1 - Pesquisa e Posiciona em um Banco de Dados
            2 - Simplesmente Mostra os Campos
            3 - Inclui registros no Bancos de Dados
            4 - Altera o registro corrente
            5 - Remove o registro corrente do Banco de Dados
        [n,5] Nivel de acesso
        [n,6] Habilita Menu Funcional
@author Willian Kazahaya
@since  10/07/2020
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Estutura da tela de Itens do Projeto

@author Willian Kazahaya
@since  10/07/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oStructOHM := FWFormStruct(2, "OHM")
	Local oModel     := FWLoadModel("JURA277")
	Local oView      := Nil
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("JURA277_VIEW", oStructOHM, "OHMMASTER")
	oView:CreateHorizontalBox("FORMFIELD", 100)
	oView:SetOwnerView("JURA277_VIEW", "FORMFIELD")
	oView:SetDescription(STR0001) // "Item de Projeto"
	oView:EnableControlBar(.T.)

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Estrutura do modelo de dados do Itens do Projeto

@author Willian Kazahaya
@since  10/07/2020
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oStructOHM := FWFormStruct(1, "OHM")
	Local oModel     := NIL
	
	oModel:= MPFormModel():New("JURA277", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields("OHMMASTER", Nil, oStructOHM, /*Pre-Validacao*/, /*Pos-Validacao*/)
	oModel:SetDescription(STR0001) // "Item de Projeto"
	oModel:GetModel("OHMMASTER"):SetDescription(STR0001) // "Item de Projeto"

Return (oModel)
