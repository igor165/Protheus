#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAE66.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAE66
Cadastro de TAGS de Pedágio 
@type Function
@author Katia Tiemi
@since 29/03/2021
@version P12 R12.1.33
@param param, param_type, param_descr
@return return, return_type, return_description
*/
Function TMSAE66()
Local oBrowse

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DME")
oBrowse:SetMenuDef("TMSAE66")
oBrowse:SetDescription(STR0001)	//Cadastro de Tags de Pedagio
oBrowse:Activate()

Return

/*{Protheus.doc} ModelDef
Definição do Modelo
@type Static Function
@author Katia Tiemi	
@since 29/03/2021
@version P12 R12.1.44
@param param, param_type, param_descr
@return return, return_type, return_description
*/
Static Function ModelDef()
Local oModel
Local oStruDME := FwFormStruct(1,"DME")
Local oStruDMF := FwFormStruct(1,"DMF")

oModel := MPFormModel():New("TMSAE66",,/*PosValid*/,/*bCommit*/, /*bCancel*/)
oModel:SetDescription(STR0002)	//Itens Tags de Pedagio

//-- Cabeçalho 
oModel:AddFields("MdFieldDME",,oStruDME,,,)
oModel:SetPrimaryKey({"DME_CODTAG"})
oModel:GetModel("MdFieldDME"):SetDescription(STR0002)	//Itens Tags de Pedagio

//-- Grid 
oModel:AddGrid("MdGridDMF","MdFieldDME",oStruDMF, /*bLinPre*/ , /*bLinPos*/ , /*bPre*/ ,  /*bPost*/, /*bLoad*/)
oModel:SetRelation("MdGridDMF",{{"DMF_FILIAL","xFilial('DMF')"},;
								{"DMF_CODTAG","DME_CODTAG"}},;
								DMF->(IndexKey(1)))
                                
oModel:GetModel("MdGridDMF"):SetDescription(STR0002)	//Itens Tags de Pedagio
oModel:GetModel("MdGridDMF"):SetUniqueLine( { 'DMF_CODOPE','DMF_TAGID' } )

oModel:SetActivate()

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@type Static Function
@author Katia Tiemi
@since 29/03/2021
@version P12 R12.1.33
@param param, param_type, param_descr
@return return, return_type, return_description
*/
Static Function ViewDef()
Local oModel   := FwLoadModel("TMSAE66")
Local oView
Local oStruDME := FwFormStruct(2,"DME")
Local oStruDMF := FwFormStruct(2,"DMF")

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define a tela principal
oView:CreateHorizontalBox("BoxSuperior",030)
oView:CreateHorizontalBox("BoxInferior",070)

oView:AddField("VwFieldCDME",oStruDME,"MdFieldDME")
oView:SetOwnerView("VwFieldCDME","BoxSuperior")

oView:AddGrid("VwGridDMF",oStruDMF,"MdGridDMF")
oView:SetOwnerView("VwGridDMF","BoxInferior")
oView:AddIncrementField("VwGridDMF","DMF_ITEM")

Return oView

/*{Protheus.doc} MenuDef
Definição do aRotina (Menu funcional)
@type Static Function
@author Katia Tiemi
@since 29/03/2021
@version P12 R12.1.23
@param param, param_type, param_descr
@return return, return_type, return_description
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0003 ACTION "AxPesqui"        OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSAE66" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAE66" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSAE66" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE STR0007 ACTION "VIEWDEF.TMSAE66" OPERATION 5 ACCESS 0

Return (aRotina)
