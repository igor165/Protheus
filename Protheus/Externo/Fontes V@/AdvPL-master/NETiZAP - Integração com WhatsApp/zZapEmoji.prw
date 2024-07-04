/* ===
    Esse � um exemplo disponibilizado no Terminal de Informa��o
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2021/09/06/como-enviar-emojis-para-whatsapp-usando-advpl-tl/
    Caso queira ver outros conte�dos envolvendo AdvPL e TL++, veja em: https://terminaldeinformacao.com/advpl/
=== */

//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function zZapEmoji
Fun��o de teste para envio de mensagens para o WhatsApp com emojis
@type  Function
@author Atilio
@since 05/08/2021
@version version
@obs A lista de emojis voc� pode ver em http://www.iemoji.com
    Navegue at� encontrar C/C++/Java Src, ent�o copie o c�digo sem as aspas
/*/

User Function zZapEmoji()
    Local aArea := GetArea()
    Local aZap  := {}
    Local cSorriso    := "\uE057"
    Local cHamburguer := "\uE120"
    Local cBacon      := "\uD83E\uDD53"
    Local cPizza      := "\uD83C\uDF55"
    Local cMensagem   := ""

    //Monta a mensagem para enviar com os emojis
    cMensagem := "Hey Dan! " + cSorriso + " "
    cMensagem += "Sei que ainda � cedo, mas que tal uma gordice? "
    cMensagem += cHamburguer + cBacon + cPizza

    //Faz o teste de envio
    aZap := u_zZapSend("5514999998888", cMensagem)

    //Se houve falha, mostra a mensagem de erro
    If ! aZap[1]
        MsgStop(aZap[2], "Falha no envio")
    EndIf

    RestArea(aArea)
Return
