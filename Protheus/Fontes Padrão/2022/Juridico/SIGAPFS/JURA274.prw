#INCLUDE "JURA274.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA274
Cadastro de Tipo de Fechamento

@author Jonatas Martins
@since  06/05/2020
/*/
//-------------------------------------------------------------------
Function JURA274()
	Local oBrowse := FWMBrowse():New()
	
	oBrowse:SetDescription(STR0001) // "Tipo de Fechamento"
	oBrowse:SetAlias("OHU")
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

@author Jonatas Martins
@since  06/05/2020
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	
	Aadd(aRotina, {STR0002, "PesqBrw"        , 0, 1, 0, .T.}) // "Pesquisar"
	Aadd(aRotina, {STR0003, "VIEWDEF.JURA274", 0, 2, 0, Nil}) // "Visualizar"
	Aadd(aRotina, {STR0004, "VIEWDEF.JURA274", 0, 3, 0, Nil}) // "Incluir"
	Aadd(aRotina, {STR0005, "VIEWDEF.JURA274", 0, 4, 0, Nil}) // "Alterar"
	Aadd(aRotina, {STR0006, "VIEWDEF.JURA274", 0, 5, 0, Nil}) // "Excluir"

Return (aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Estutura da tela de 

@author Jonatas Martins
@since  06/05/2020
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oStructOHU := FWFormStruct(2, "OHU")
	Local oModel     := FWLoadModel("JURA274")
	Local oView      := Nil
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField("JURA274_VIEW", oStructOHU, "OHUMASTER")
	oView:CreateHorizontalBox("FORMFIELD", 100)
	oView:SetOwnerView("JURA274_VIEW", "FORMFIELD")
	oView:SetDescription(STR0001) // "Tipo de Fechamento"
	oView:EnableControlBar(.T.)

Return (oView)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Estrutura do modelo de dados do Tipo de Fechamento

@author Jonatas Martins
@since  06/05/2020
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
	Local oStructOHU := FWFormStruct(1, "OHU")
	Local oModel     := NIL
	
	oModel:= MPFormModel():New("JURA274", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/, /*Cancel*/)
	oModel:AddFields("OHUMASTER", Nil, oStructOHU, /*Pre-Validacao*/, /*Pos-Validacao*/)
	oModel:SetDescription(STR0008) // "Modelo Tipo de Fechamento"
	oModel:GetModel("OHUMASTER"):SetDescription(STR0001) // "Tipo de Fechamento"

Return (oModel)