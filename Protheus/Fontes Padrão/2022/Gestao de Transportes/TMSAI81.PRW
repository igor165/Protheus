#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI81.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAI81
Fontes de Integração
@type Function
@author Valdemar Roberto Mognon
@since 25/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI81()
(examples)
@see (links_or_references)
*/

Function TMSAI81()
Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DN6")
oBrowse:SetMenuDef("TMSAI81")
oBrowse:SetDescription(STR0001)	//-- Fontes de Integração
oBrowse:Activate()

Return

/*{Protheus.doc} MenuDef
    Definição do aRotina (Menu funcional)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 25/02/2022
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MenuDef()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0	//-- Pesquisar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAI81" OPERATION 2 ACCESS 0	//-- Visualizar
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSAI81" OPERATION 3 ACCESS 0	//-- Incluir
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAI81" OPERATION 4 ACCESS 0	//-- Alterar
ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSAI81" OPERATION 5 ACCESS 0	//-- Excluir

Return (aRotina)

/*{Protheus.doc} ModelDef
Definição do Modelo
@type Static Function
@author Valdemar Roberto Mognon
@since 25/02/2022
@version P12 R12.1.20
@param param, param_type, param_descr
@return return, return_type, return_description
@example ModelDef()
(examples)
@see (links_or_references)
*/

Static Function ModelDef()
Local oModel
Local oStruDN6 := FwFormStruct(1,"DN6")

oModel := MpFormModel():New("TMSAI81", /*bPreValidacao*/, /*bPosValidacao*/ , /*bCommit*/ , /*bCancel*/ )
oModel:SetDescription(STR0001)	//-- Fontes de Integração

//-- Cabeçalho
oModel:AddFields("MdFieldDN6",,oStruDN6,,,)
oModel:SetPrimaryKey({"DN6_CODIGO"})
oModel:GetModel("MdFieldDN6"):SetDescription(STR0001)	//-- Fontes de Integração

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@type Static Function
@author Valdemar Roberto Mognon
@since 25/02/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example ViewDef()
(examples)
@see (links_or_references)
*/

Static Function ViewDef()
Local oModel   := FwLoadModel("TMSAI81")
Local oStruDN6 := FwFormStruct(2,"DN6")
Local oView

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define o tamanho da tela principal
oView:CreateHorizontalBox("Cabecalho",100)

//-- Cria área da tabela pai
oView:AddField("VwFieldDN6",oStruDN6,"MdFieldDN6") 
oView:EnableTitleView("VwFieldDN6",STR0001)	//-- Fontes de Integração
oView:SetOwnerView("VwFieldDN6","Cabecalho")

Return oView
