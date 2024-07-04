#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI83.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAI83
Relacionamento entre Registros
@type Function
@author Valdemar Roberto Mognon
@since 02/03/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI83()
(examples)
@see (links_or_references)
*/

Function TMSAI83()
Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DN4")
oBrowse:SetMenuDef("TMSAI83")
oBrowse:SetDescription(STR0001)	//-- Relacionamento entre Registros
oBrowse:Activate()

Return

/*{Protheus.doc} MenuDef
    Definição do aRotina (Menu funcional)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 02/03/2022
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
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAI83" OPERATION 2 ACCESS 0	//-- Visualizar

Return (aRotina)

/*{Protheus.doc} ModelDef
Definição do Modelo
@type Static Function
@author Valdemar Roberto Mognon
@since 02/03/2022
@version P12 R12.1.20
@param param, param_type, param_descr
@return return, return_type, return_description
@example ModelDef()
(examples)
@see (links_or_references)
*/

Static Function ModelDef()
Local oModel
Local oStruDN4 := FwFormStruct(1,"DN4")

oModel := MpFormModel():New("TMSAI83", /*bPreValidacao*/, /*bPosValidacao*/ , /*bCommit*/ , /*bCancel*/ )
oModel:SetDescription(STR0001)	//-- Relacionamento entre Registros

//-- Cabeçalho
oModel:AddFields("MdFieldDN4",,oStruDN4,,,)
oModel:SetPrimaryKey({"DN4_CODFON","DN4_CODREG"})
oModel:GetModel("MdFieldDN4"):SetDescription(STR0001)	//-- Relacionamento entre Registros

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@type Static Function
@author Valdemar Roberto Mognon
@since 02/03/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example ViewDef()
(examples)
@see (links_or_references)
*/

Static Function ViewDef()
Local oModel   := FwLoadModel("TMSAI83")
Local oStruDN4 := FwFormStruct(2,"DN4")
Local oView

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define o tamanho da tela principal
oView:CreateHorizontalBox("Cabecalho",100)

//-- Cria área da tabela pai
oView:AddField("VwFieldDN4",oStruDN4,"MdFieldDN4") 
oView:EnableTitleView("VwFieldDN4",STR0001)	//-- Relacionamento entre Registros
oView:SetOwnerView("VwFieldDN4","Cabecalho")

Return oView
