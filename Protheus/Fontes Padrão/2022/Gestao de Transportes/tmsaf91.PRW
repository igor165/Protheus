#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAF91.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAF91
Configuração da Automatização da Viagem Modelo 3
@type Function
@author Valdemar Roberto Mognon
@since 03/02/2021
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAF60()
(examples)
@see (links_or_references)
*/
Function TMSAF91()
Local oBrowse

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DM9")
oBrowse:SetMenuDef("TMSAF91")
oBrowse:SetDescription(STR0001)	//-- Configuração da Automatização da Viagem Modelo 3
oBrowse:Activate()

Return

/*{Protheus.doc} ModelDef
Definição do Modelo
@type Static Function
@author Valdemar Roberto Mognon
@since 03/02/2021
@version P12 R12.1.20
@param param, param_type, param_descr
@return return, return_type, return_description
@example ModelDef()
(examples)
@see (links_or_references)
*/
Static Function ModelDef()
Local oModel
Local oStruDM9 := FwFormStruct(1,"DM9")
Local oStruDMA := FwFormStruct(1,"DMA")

oModel := MPFormModel():New("TMSAF91",,/*PosValid*/,/*bCommit*/, /*bCancel*/)
oModel:SetDescription(STR0002)	//-- Configuração

//-- Cabeçalho da Configuração
oModel:AddFields("MdFieldDM9",,oStruDM9,,,)
oModel:SetPrimaryKey({"DM9_CODAUT"})
oModel:GetModel("MdFieldDM9"):SetDescription(STR0002)	//-- Configuração

//-- Grid das Configurações de Automatização
oModel:AddGrid("MdGridDMA","MdFieldDM9",oStruDMA, /*bLinPre*/ , /*bLinPos*/ , /*bPre*/ ,  /*bPost*/, /*bLoad*/)
oModel:SetRelation("MdGridDMA",{{"DMA_FILIAL","xFilial('DMA')"},;
								{"DMA_CODAUT","DM9_CODAUT"}},;
								DMA->(IndexKey(1)))
oModel:GetModel("MdGridDMA"):SetDescription(STR0003)	//-- Rotinas
oModel:GetModel("MdGridDMA"):SetUniqueLine({"DMA_ROTINA"})

oModel:SetActivate()

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@type Static Function
@author Valdemar Roberto Mognon
@since 03/02/2021
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example ViewDef()
(examples)
@see (links_or_references)
*/
Static Function ViewDef()
Local oModel   := FwLoadModel("TMSAF91")
Local oView
Local oStruDM9 := FwFormStruct(2,"DM9")
Local oStruDMA := FwFormStruct(2,"DMA")

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define a tela principal
oView:CreateHorizontalBox("BoxSuperior",030)
oView:CreateHorizontalBox("BoxInferior",070)

oView:AddField("VwFieldCDM9",oStruDM9,"MdFieldDM9")
oView:SetOwnerView("VwFieldCDM9","BoxSuperior")

oView:AddGrid("VwGridDMA",oStruDMA,"MdGridDMA")
oView:SetOwnerView("VwGridDMA","BoxInferior")
oView:AddIncrementField("VwGridDMA","DMA_SEQUEN")

Return oView

/*{Protheus.doc} MenuDef
Definição do aRotina (Menu funcional)
@type Static Function
@author Valdemar Roberto Mognon
@since 03/02/2021
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example MenuDef()
(examples)
@see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0004 ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAF91" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSAF91" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.TMSAF91" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE STR0008 ACTION "VIEWDEF.TMSAF91" OPERATION 5 ACCESS 0

Return (aRotina)
