#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"
#Include "PLINTEGDEPARA.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLIntegDePara
De/para de Integrações do Plano de Saúde

@author Vinicius Queiros Teixeira
@since 17/03/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
Function PLIntegDePara()

	Local oBrowse := Nil
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("B7V")
	oBrowse:SetDescription(STR0001) // "De/Para de Integrações"

    oBrowse:AddLegend("B7V_ATIVO == '0'", "RED", STR0002) // "De/para desativado" 
    oBrowse:AddLegend("B7V_ATIVO == '1'", "GREEN", STR0003) // "De/para ativado" 

    oBrowse:SetMenuDef("PLIntegDePara")
    
    oBrowse:Activate()
		
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu do De/para de Integrações

@author Vinicius Queiros Teixeira
@since 17/03/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina := {}

	ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.PLIntegDePara" OPERATION 2 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.PLIntegDePara" OPERATION 3 ACCESS 0 // "Incluir"
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.PLIntegDePara" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.PLIntegDePara" OPERATION 5 ACCESS 0 // "Excluir"
    ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.PLIntegDePara" OPERATION 8 ACCESS 0 // "Imprimir"
    ADD OPTION aRotina TITLE STR0009 ACTION "VIEWDEF.PLIntegDePara" OPERATION 9 ACCESS 0 // "Copiar"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo do De/para de Integrações

@author Vinicius Queiros Teixeira
@since 17/03/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

	Local oModel := Nil
    Local oStruB7V := FWFormStruct(1, "B7V")
  
	oModel := MPFormModel():New("PLIntegDePara")
	oModel:SetDescription(STR0001) // "De/para de Integrações"

	oModel:AddFields("MASTERB7V",, oStruB7V)

    oModel:GetModel("MASTERB7V"):SetDescription(STR0010) // "Cadastro de De/para de Integrações"

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View do De/para de Integrações

@author Vinicius Queiros Teixeira
@since 17/03/2022
@version Protheus 12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oModel := FWLoadModel("PLIntegDePara")
	Local oView := Nil
    Local oStruB7V := FWFormStruct(2, "B7V")

	oView := FWFormView():New()
	oView:SetModel(oModel)

    oView:AddField("FORM_DEPARA", oStruB7V, "MASTERB7V") 
	
    oView:CreateHorizontalBox("BOX_FORM", 100)
    
    oView:SetOwnerView("FORM_DEPARA", "BOX_FORM")
	
Return oView