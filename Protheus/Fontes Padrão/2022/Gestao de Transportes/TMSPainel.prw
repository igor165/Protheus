#Include "Protheus.ch"
#Include "Topconn.ch"

/*{Protheus.doc} TMSPainel
    Classe para criação de paineis de visualização de informações
    @type Function
    @author Felipe Barbiere
    @since 17/08/2021
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    (examples)
    @see (links_or_references)
*/
//Classe Painel
Class TMSPainel
    Data oPainel
    Data oTitulo
    Data oValor
    Data oIcone

    Data nX
    Data nY
    Data nAltura
    Data nLargura

    Data cTitulo
    Data cValor
    Data nCorFundo
    Data oFonteTitulo
    Data oFonteValor
    Data cIcone

    Data nXTitulo
    Data nYTitulo
    Data nXValor
    Data nYValor
    Data lMarcado

    Method New()
    Method MntTela()
    Method AtuValor()
EndClass

//-----------------------------------------------------------------
/*/{Protheus.doc} New()
Método construtor da classe

@author Felipe Barbiere
@since 17/08/2021
@version 1.0
/*/
Method New(oTela, cTitulo, cValor, aRGB, cIcone, nX, nY, nLargura, nAltura) Class TMSPainel
    DEFAULT cTitulo := ""
    DEFAULT cValor  := ""
    DEFAULT aRGB    := {0, 0, 0}
    DEFAULT cIcone  := ""
    DEFAULT nX      := 5
    DEFAULT nY      := 5
    DEFAULT nLargura:= 110
    DEFAULT nAltura := 050

    ::nX        := nX //Coluna inicial
    ::nY        := nY //Linha inicial
    ::nAltura   := nAltura //60 //Altura
    ::nLargura  := nLargura //120 //Largura
    ::cTitulo   := cTitulo //Titulo do Painel
    ::cValor    := cValor //Valor a ser mostrado
    ::nCorFundo := RGB(aRGB[1], aRGB[2], aRGB[3]) //Cor de Fundo em RGB

    ::nXTitulo  := (::nLargura/100) * 15 //Coorrdenadas posicao inicial
    ::nYTitulo  := (::nAltura/100) * 15 //Coorrdenadas posicao inicial

    ::nXValor   := (::nLargura/100) * 20 //Coorrdenadas posicao inicial
    ::nYValor   := (::nAltura/100) * 45 //Coorrdenadas posicao inicial

    ::oFonteTitulo := TFont():New('Helvetica',,20,.T.) //Fonte do Titulo
    ::oFonteValor := TFont():New('Helvetica',,40,.T.,.T.) //Fonte do valor
    ::cIcone := cIcone
    ::lMarcado  := .T.

    ::MntTela(oTela)
Return(Self)

//-----------------------------------------------------------------
/*/{Protheus.doc} MntTela(oTela)
Método para montagem da tela

@author Felipe Barbiere
@since 17/8/2021
@version 1.0
/*/
Method MntTela(oTela) Class TMSPainel
    //Local oIcone

    ::oPainel     := TPanel():New(::nY, ::nX, "",oTela, ,.T., , , ::nCorFundo, ::nLargura, ::nAltura, .F., .F.) //Cria o Painel (area colorida)

    If(!Empty(::cIcone)) //Verificar aqui se icone existe no RPO
        ::oIcone  := TBitmap():New(015, 005, 076, 076, , ::cIcone, .T., ::oPainel, {||}, , .F., .F., , , .F., , .T., , .F.) //Coloca o ícone no Painel
        ::oIcone:lAutoSize := .T.
    Endif

    ::oTitulo := TSay():New(::nYTitulo, ::nXTitulo, {|| ::cTitulo}, ::oPainel, , ::oFonteTitulo, , , , .T., CLR_WHITE, CLR_WHITE, 200, 20) //Escreve um Titulo dentro do Painel
    ::oValor  := TSay():New(::nYValor, ::nXValor, {|| ::cValor}, ::oPainel, , ::oFonteValor, , , , .T., CLR_WHITE, CLR_WHITE, 200, 30) //Escreve um Valor dentro do Painel

Return()

//-----------------------------------------------------------------
/*/{Protheus.doc} AtuValor(oTela)
//Atualiza o valor do painel

@author Felipe Barbiere
@since 17/8/2021
@version 1.0
/*/
Method AtuValor(cValor) Class TMSPainel
    ::oValor:cTitle     := cValor
    ::oValor:cCaption   := cValor
Return()