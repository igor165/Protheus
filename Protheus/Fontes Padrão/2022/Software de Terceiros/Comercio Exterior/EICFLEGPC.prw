#Include 'Protheus.ch'
#Include "Average.ch"
#INCLUDE "FWMVCDEF.CH"
#include "shell.ch" 
#include "fileio.ch"
/*
Funcao     : EICFLEGPC()
Parametros : Nenhum
Retorno    : NIL
Objetivos  : Cadastro de Fundamento Legal para PIS e COFINS
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 09/04/2014 :: 17:22
*/
*------------------------*
Function EICFLEGPC()
*------------------------*
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SJY")
oBrowse:SetMenuDef("EICFLEGPC")
oBrowse:SetDescription("Fundamento Legal para PIS e COFINS")
oBrowse:Activate()

Return

*------------------------*
Static Function MenuDef()
*------------------------*                                   
Local aRotina := {}

ADD OPTION aRotina TITLE "Visualizar"                  ACTION "VIEWDEF.EICFLEGPC" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"                     ACTION "VIEWDEF.EICFLEGPC" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"                     ACTION "VIEWDEF.EICFLEGPC" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"                     ACTION "VIEWDEF.EICFLEGPC" OPERATION 5 ACCESS 0

Return aRotina

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruSJY := FWFormStruct(1,"SJY")

oModel := MPFormModel():New("EICFLEGPC")

oModel:AddFields("SJYMASTER",, oStruSJY) 

oModel:SetPrimaryKey({"JY_FILIAL", "JY_CODIGO"}) 

oModel:SetDescription(TESX2Name("SJY"))

Return oModel
*------------------------*
Static Function ViewDef()
*------------------------*
Local oModel   := FWLoadModel("EICFLEGPC")
Local oStruSJY := FWFormStruct(2,"SJY",,)
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField("VIEW_SJY", oStruSJY, "SJYMASTER")

oView:CreateHorizontalBox("TOTAL" , 100)

oView:SetOwnerView("VIEW_SJY", "TOTAL")

oView:EnableTitleView("VIEW_SJY", "Fundamento Legal para PIS e COFINS", RGB(240,248,255)) 

oView:EnableControlBar(.T.)

Return oView