User Function COMP024_MVC()
    Local aCoors := FWGetDialogSize( oMainWnd )
    Local oPanelUp, oFWLayer, oPanelLeft, oPanelRight, oBrowseUp, oBrowseLeft, oBrowseRight,    oRelacZA4, oRelacZA5
    Private oDlgPrinc
    Define MsDialog oDlgPrinc Title 'Multiplos FWmBrowse' From aCoors[1], aCoors[2] To aCoors[3],    aCoors[4] Pixel
    //
    // Cria o conteiner onde serão colocados os browses
    //
    oFWLayer     := FWLayer()      :New()
    oFWLayer:Init( oDlgPrinc, .F., .T. )
    //
    // Define Painel Superior
    //
    oFWLayer:AddLine( 'UP' , 50, .F. )
    // Cria uma "linha" com 50% da tela
    oFWLayer:AddCollumn( 'ALL' , 100, .T., 'UP' )
    // Na "linha" criada eu crio uma coluna com 100% da tamanho dela
    oPanelUp     := oFWLayer:GetColPanel( 'ALL' , 'UP' )
    // Pego o objeto desse pedaço do container
    //
    // Painel Inferior
    //
    oFWLayer:AddLine( 'DOWN' , 50, .F. )
    // Cria uma "linha" com 50% da tela
    oFWLayer:AddCollumn( 'LEFT' , 50, .T., 'DOWN' )
    // Na "linha" criada eu crio uma coluna com 50% da tamanho dela
    oFWLayer:AddCollumn( 'RIGHT' , 50, .T., 'DOWN' )
    // Na "linha" criada eu crio uma coluna com 50% da tamanho delaAdvPl utilizando MVC – 79
    oPanelLeft   := oFWLayer:GetColPanel( 'LEFT' , 'DOWN' ) // Pego o objeto do pedaço esquerdo
    oPanelRight  := oFWLayer:GetColPanel( 'RIGHT' , 'DOWN' ) // Pego o objeto do pedaço direito
    //
    // FWmBrowse Superior Albuns
    //
    oBrowseUp    := FWmBrowse()    :New()
    oBrowseUp:SetOwner( oPanelUp )
    // Aqui se associa o browse ao componente de tela
    oBrowseUp:SetDescription( "Albuns" )
    oBrowseUp:SetAlias( 'ZA3' )
    oBrowseUp:SetMenuDef( 'COMP024_MVC' )
    // Define de onde virao os botoes deste browse
    oBrowseUp:SetProfileID( '1' )
    oBrowseUp:ForceQuitButton()
    oBrowseUp:Activate()
    //
    // Lado Esquerdo Musicas
    //
    oBrowseLeft  := FWMBrowse()    :New()
    oBrowseLeft:SetOwner( oPanelLeft )
    oBrowseLeft:SetDescription( 'Musicas' )
    oBrowseLeft:SetMenuDef( '' )
    // Referencia vazia para que nao exiba nenhum botao
    oBrowseLeft:DisableDetails()
    oBrowseLeft:SetAlias( 'ZA4' )
    oBrowseLeft:SetProfileID( '2' )
    oBrowseLeft:Activate()
    //
    // Lado Direito Autores/Interpretes
    //
    oBrowseRight := FWMBrowse()    :New()
    oBrowseRight:SetOwner( oPanelRight )
    oBrowseRight:SetDescription( 'Autores/Interpretes' )
    oBrowseRight:SetMenuDef( '' )
    // Referencia vazia para que nao exiba nenhum botao
    oBrowseRight:DisableDetails()
    oBrowseRight:SetAlias( 'ZA5' )
    //80 - AdvPl utilizando MVC
    oBrowseRight:SetProfileID( '3' )
    oBrowseRight:Activate()
    //
    // Relacionamento entre os Paineis
    oRelacZA4    := FWBrwRelation():New()
    oRelacZA4:AddRelation( oBrowseUp , oBrowseLeft , {{ 'ZA4_FILIAL' , 'xFilial( "ZA4" )' }, { 'ZA4_ALBUM' , 'ZA3_ALBUM' }} )
    oRelacZA4:Activate()
    oRelacZA5    := FWBrwRelation():New()
    oRelacZA5:AddRelation( oBrowseLeft, oBrowseRight, {{ 'ZA5_FILIAL' , 'xFilial( "ZA5" )' }, { 'ZA5_ALBUM' , 'ZA4_ALBUM' }, { 'ZA5_MUSICA' , 'ZA4_MUSICA' }} )
    oRelacZA5:Activate()
    Activate MsDialog oDlgPrinc Center
Return
