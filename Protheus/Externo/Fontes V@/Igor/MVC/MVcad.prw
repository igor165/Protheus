#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

USER FUNCTION MVcad()
    LOCAL oBrowse
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias('ZA0')
    oBrowse:SetDescription('Cadastro de produtos')
    oBrowse:AddLegend( "ZA0_TIPO=='1'", "YELLOW", "Autor"      )
    oBrowse:AddLegend( "ZA0_TIPO=='2'", "BLUE"  , "Interprete" )
    oBrowse:ACTIVATE()    
RETURN NIL

Static Function MenuDef()
    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.MVcad' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.MVcad' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.MVcad' OPERATION 4 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'      ACTION 'VIEWDEF.MVcad' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Imprimir'     ACTION 'VIEWDEF.MVcad' OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE 'Copiar'       ACTION 'VIEWDEF.MVcad' OPERATION 9 ACCESS 0    
Return aRotina

Static Function ModelDef()
    Local oStruZ09 := FWFormStruct( 1, 'ZA0', , /*bAvalCampo*/,/*lViewUsado*/ )
    /*
     FWFormStruct nTipo := {
         1 = Model
         2 = View
     } ,,,

     Alias 'Z09'     
    */
    Local oModel

    //Cria o objeto do Modelo de Dados 
    oModel := MPFormModel():New('MVcad')

    // Adiciona ao modelo uma estrutura de formulário de edição por campo
    oModel:AddFields('ZAOTotvsHomo33', /*cOwner*/,oStruZ09,/*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

    oModel:SetDescription('Modelo de Dados e Igor')

    oModel:GetModel('ZAOTotvsHomo33'):SetDescription('Dados de Igor')

Return oModel

Static Function ViewDef()
    Local oModel := FWLoadModel('MVcad')
    Local oStruZ09 := FWFormStruct(2,'ZA0')

    Local oView
    Local cCampos := {}

    oView := FWFormView():New()

    // Define qual o Modelo de dados será utilizado
    oView:SetModel(oModel)

    //Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
    oView:AddField('VIEW_ZA0',oStruZ09,'ZAOTotvsHomo33')

    // Criar um "box" horizontal para receber algum elemento da view
    oView:CreateHorizontalBox('Screen',100)

    // Relaciona o ID da View com o "box" para exibicao
    oView:SetOwnerView('VIEW_ZA0','Screen')

Return oView

Static Function MVcadPOS( oModel )
/*
https://tdn.Totvs.com/display/public/PROT/Pontos_de_Entrada_do_MVC_na_rotina_de_cadastro_de_naturezas_FINA010
*/
Local nOperation := oModel:GetOperation()
Local lRet       := .T.

if nOperation == MODEL_OPERATION_UPDATE
    IF Empty(oModel:GetValue('ZAOTotvsHomo33','ZA0_CODIGO')) 
        Help( ,, 'HELP' ,, 'Informe o Código',1,0)
        lRet := .F.
    ENDIF    
endif
Return lRet
