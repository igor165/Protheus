#Include 'Protheus.ch'
#Include "Average.ch"
#INCLUDE "FWMVCDEF.CH"
#include "shell.ch" 
#include "fileio.ch"
/*
Funcao     : EICFREDPC()
Parametros : Nenhum
Retorno    : NIL
Objetivos  : Cadastro de Fundamento Legal de Redução de Base para PIS e COFINS
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 09/04/2014 :: 17:14
*/
*------------------------*
Function EICFREDPC()
*------------------------*
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SJZ")
oBrowse:SetMenuDef("EICFREDPC")
oBrowse:SetDescription("Fundamento Legal de Redução de Base para PIS e COFINS")
oBrowse:Activate()

Return

*------------------------*
Static Function MenuDef()
*------------------------*                                   
Local aRotina := {}

ADD OPTION aRotina TITLE "Visualizar"                  ACTION "VIEWDEF.EICFREDPC" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"                     ACTION "VIEWDEF.EICFREDPC" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"                     ACTION "VIEWDEF.EICFREDPC" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"                     ACTION "VIEWDEF.EICFREDPC" OPERATION 5 ACCESS 0

Return aRotina

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oModel
Local oStruSJZ := FWFormStruct(1 , "SJZ")

oModel := MPFormModel():New("EICFREDPC")  

oModel:AddFields("SJZMASTER",,oStruSJZ)

oModel:SetPrimaryKey({"JZ_FILIAL", "JZ_CODIGO", "JZ_NCM"}) 

oModel:SetDescription("Fundamento Legal de Redução de Base para PIS e COFINS")

Return oModel

*------------------------*
Static Function ViewDef()
*------------------------*
Local oModel := FWLoadModel("EICFREDPC")
Local oStruSJZ := FWFormStruct(2 , "SJZ")
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField("VIEW_SJZ", oStruSJZ, "SJZMASTER") 

oView:CreateHorizontalBox("TOTAL"  , 100)

oView:SetOwnerView( "VIEW_SJZ" , "TOTAL")

oView:EnableTitleView("VIEW_SJZ", "Fundamento Legal de Redução de Base para PIS e COFINS", RGB(240,248,255)) 

oView:EnableControlBar(.T.)

Return oView