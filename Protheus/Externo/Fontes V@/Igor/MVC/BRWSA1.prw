#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

USER FUNCTION BRWZWP()
    Local   aArea := GetNextAlias()
    Local   oBrowseZWP 
    Private aRotina := MenuDef()

    oBrowseZWP := FWMBrowse():New()
    oBrowseZWP:SetAlias("ZWP")
    oBrowseZWP:SetDescription("Cadastro de Clientes")
    oBrowseZWP:SetMenuDef("BRWZWP")
    oBrowseZWP:Activate()
    RestArea(aArea)
RETURN NIL

STATIC FUNCTION ModelDef()
    Local oStruZWP := FWFormStruct( 1, "ZWP" /*bAvalCampo*/,/*lViewUsado*/ )
    Local oModel
    
    oModel := MpFormModel():New("BRWZWPM")
    oModel:AddFields("ZWPTotvsHomo33", /*cOwner*/ , oStruZWP, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
    oModel:SetPrimaryKey({'WP_FILIAL','WP_CODIGO'})
    oModel:SetDescription("Cadastro de Clientes")
    oModel:GetModel("ZWPTotvsHomo33"):SetDescription("Cadastro de Clientes")

RETURN oModel

STATIC FUNCTION ViewDef()
    Local oModel := FWLoadModel( "BRWZWPM")
    Local oStruZWP := FWFormStruct(2,"ZWP")
    Local oView := FWFormView():New()
    /* Local cCampos := {} */

    oView:SetModel(oModel)
    oView:AddField("VIEW_ZWP",oStruZWP,"ZWPTotvsHomo33")
    oView:EnableTitleView('VIEW_ZWP','Dados do Sites')
    oView:CreateHorizontalBox("Screen",100)
    oView:SetCloseOnOk({||.T.})
    oView:SetOwnerView("VIEW_ZWP","Screen")    

RETURN oView

Static Function MenuDef()
    Local aRotina := {}
    ADD OPTION aRotina TITLE "Visualizar"   ACTION "VIEWDEF.BRWZWP" OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE "Incluir"      ACTION "VIEWDEF.BRWZWP" OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE "Alterar"      ACTION "VIEWDEF.BRWZWP" OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE "Excluir"      ACTION "VIEWDEF.BRWZWP" OPERATION 5 ACCESS 0
Return aRotina

/* Static Function MVcadPOS( oModel )
/*
https://tdn.Totvs.com/display/public/PROT/Pontos_de_Entrada_do_MVC_na_rotina_de_cadastro_de_naturezas_FINA010

Local nOperation := oModel:GetOperation()
Local lRet       := .T.

if nOperation == MODEL_OPERATION_UPDATE
    IF Empty(oModel:GetValue("ZWPTotvsHomo33","ZWP_COD"))
        Help( ,, "HELP" ,, "Informe o Código",1,0)
        lRet := .F.
    ENDIF
endif
Return lRet  */ 

/* Static Function BRWCAD()
    Local lRet      := .T.
    Local aDados    := {}



RETURN lRet
 */
