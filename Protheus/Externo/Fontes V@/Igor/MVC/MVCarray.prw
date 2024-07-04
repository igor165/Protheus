#include 'TOTVS.CH'

Static Function FWMVCMenu()
    Local aRotina := {}

    ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.COMP021_MVC' OPERATION 2 ACCESS 0
    ADD OPTION aRotina Title 'Incluir' Action 'VIEWDEF.COMP021_MVC' OPERATION 3 ACCESS 0
    ADD OPTION aRotina Title 'Alterar' Action 'VIEWDEF.COMP021_MVC' OPERATION 4 ACCESS 0
    ADD OPTION aRotina Title 'Excluir' Action 'VIEWDEF.COMP021_MVC' OPERATION 5 ACCESS 0
    ADD OPTION aRotina Title 'Imprimir' Action 'VIEWDEF.COMP021_MVC' OPERATION 8 ACCESS 0
    ADD OPTION aRotina Title 'Copiar' Action 'VIEWDEF.COMP021_MVC' OPERATION 9 ACCESS 0

Return aRotina

User Function MVCBrow()
    oBrowse := FWMBrowse():New()

    oBrowse:SetAlias('Z09')

    oBrowse:SetDescription('Cadastro de Idade:')

    oBrowse:AddLegend("Z09=='1'", "RED", "Cadastro de idade")
    oBrowse:SetFilterDefault("Z09=='1'")
    oBrowse:Activate()
Return nil


