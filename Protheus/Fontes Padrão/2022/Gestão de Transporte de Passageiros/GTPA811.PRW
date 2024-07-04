#Include "GTPA811.ch"
#Include "Protheus.ch"
#Include "FWMVCDEF.CH"


//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA811
Funç?o responsavel pela definiç?o da view
@type Function
@author GTP
@since 07/08/2019
@version 1.0 
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Function GTPA811()
Local oBrowse       := FWMBrowse():New()

oBrowse:SetAlias('G5B')

oBrowse:SetMenuDef('GTPA811')
oBrowse:SetDescription(STR0001)        //'Referência GTP x TMS'

oBrowse:Activate()
oBrowse:Destroy()

GTPDestroy(oBrowse)

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funç?o responsavel pela definiç?o do menu
@type Static Function
@author GTP
@since 07/08/2019
@version 1.0
@return aRotina, retorna as opç?es do menu
/*/
//------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {} 

    ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.GTPA811' OPERATION OP_VISUALIZAR	ACCESS 0 // Visualizar
    ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.GTPA811' OPERATION OP_INCLUIR		ACCESS 0 // Incluir
    ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.GTPA811' OPERATION OP_ALTERAR		ACCESS 0 // Alterar
    ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.GTPA811' OPERATION OP_EXCLUIR		ACCESS 0 // Excluir

    ADD OPTION aRotina TITLE 'Pesquisar'	ACTION 'VIEWDEF.GTPA811' OPERATION OP_PESQUISAR	ACCESS 0 // Pesquisar
    ADD OPTION aRotina TITLE 'Imprimir'		ACTION 'VIEWDEF.GTPA811' OPERATION OP_IMPRIMIR	ACCESS 0 // Imprimir
    ADD OPTION aRotina TITLE 'Cópia'		ACTION 'VIEWDEF.GTPA811' OPERATION OP_COPIA		ACCESS 0 // Cópia

Return aRotina

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef 
Funç?o responsavel pela definiç?o do modelo
@type Static Function
@author GTP
@since 07/08/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrG5B	:= FWFormStruct(1,'G5B')

oModel := MPFormModel():New('GTPA811', /*bPreValidacao*/, /*bPosValid*/, /*bCommit*/, /*bCancel*/ )

oModel:AddFields('G5BMASTER',/*cOwner*/,oStrG5B,/*bPre*/,/*bPos*/,/*bLoad*/)

oModel:SetDescription(STR0001)

oModel:GetModel('G5BMASTER'):SetDescription(STR0001)	//'Ref. GTP x TMS' 

oModel:SetPrimaryKey({'G5B_FILIAL','G5B_ALIASD','G5B_VALORD','G5B_ALIASP','G5B_VALORP','G5B_TIPO','G5B_FILDES'})

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funç?o responsavel pela definiç?o da view
@type Static Function
@author GTP
@since 07/08/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA811')
Local oStrG5B	:= FWFormStruct(2, 'G5B')

oView:SetModel(oModel)

oView:AddField('VIEW_G5B' ,oStrG5B,'G5BMASTER')

oView:CreateHorizontalBox('TELA', 100)

oView:SetOwnerView('VIEW_G5B','TELA')

oView:SetDescription(STR0001) //'Ref. GTP x TMS'

Return oView


