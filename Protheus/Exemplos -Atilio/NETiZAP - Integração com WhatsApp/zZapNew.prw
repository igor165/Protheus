/* ===
    Esse � um exemplo disponibilizado no Terminal de Informa��o
    Confira o artigo sobre esse assunto, no seguinte link: https://terminaldeinformacao.com/2021/09/13/como-quebrar-linhas-em-mensagens-do-whatsapp-usando-advpl-tl/
    Caso queira ver outros conte�dos envolvendo AdvPL e TL++, veja em: https://terminaldeinformacao.com/advpl/
=== */

//Bibliotecas
#Include "TOTVS.ch"

/*/{Protheus.doc} User Function MA040TOK
Fun��o na valida��o do cadastro de vendedores
@type  Function
@author Atilio
@since 06/08/2021
@version version
@see https://tdn.totvs.com/pages/releaseview.action?pageId=6784256
/*/

User Function MA040TOK()
    Local aArea       := GetArea()
    Local lRet        := .T.    
    Local cNome       := ""
    Local cDDD        := ""
    Local cTelefone   := ""
    Local cApertoMao  := "\uD83E\uDD1D"
    Local cBraco      := "\uE14C"
    Local cMaosJuntas := "\uE41D"
    Local cMensagem   := ""
    Local aZap        := {}

    //Se for inclus�o
    If INCLUI

        //Se tiver o nome reduzido, usa ele, do contr�rio, usa o nome
        If ! Empty(M->A3_NREDUZ)
            cNome := Alltrim(M->A3_NREDUZ)
        Else
            cNome := Alltrim(M->A3_NOME)
        EndIf
        cNome := Capital(cNome)

        //Pega o DDD, e se o usu�rio ter digitado 3 caracteres, retira o primeiro, por exemplo, 014 -> 14
        cDDD := Alltrim(M->A3_DDDTEL)
        If Len(cDDD) == 3
            cDDD := SubStr(cDDD, 2)
        EndIf

        //Pega o Telefone e retira os espa�os
        cTelefone := Alltrim(M->A3_TEL)

        //Se tiver DDD e Telefone
        If ! Empty(cDDD) .And. ! Empty(cTelefone)

            //Monta a mensagem que ser� enviada ao vendedor
            cMensagem := 'Ol� <b>' + cNome + '</b> ' + cApertoMao + '<br>' + CRLF
            cMensagem += '<br>' + CRLF
            cMensagem += 'Seja bem vindo ao nosso time de Vendedores e Representantes ' + cBraco + '<br>' + CRLF
            cMensagem += '<br>' + CRLF
            cMensagem += 'Esperamos que a parceria seja pr�spera e duradoura ' + cMaosJuntas + '<br>' + CRLF
            cMensagem += '<br>' + CRLF
            cMensagem += 'Atenciosamente,<br>' + CRLF
            cMensagem += '<br>' + CRLF
            cMensagem += '<i>Fam�lia Terminal de Informa��o</i>' + CRLF

            //Faz o envio da mensagem
            aZap := u_zZapSend("55" + cDDD + cTelefone, cMensagem)

            //Se houve falha, mostra a mensagem de erro
            If ! aZap[1]
                MsgStop(aZap[2], "Falha no envio")
            EndIf
        EndIf
    EndIf

    RestArea(aArea)
Return lRet

/*/{Protheus.doc} User Function CUSTOMERVENDOR
Ponto de Entrada no padr�o MVC acionado no cadastro de Fornecedores
@type  Function
@author Atilio
@since 06/08/2021
@version version
@see https://centraldeatendimento.totvs.com/hc/pt-br/articles/360016405952-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-Ponto-de-entrada-MVC-para-as-rotinas-MATA010-MATA020-e-MATA030
/*/

User Function CUSTOMERVENDOR()
    Local aArea      := GetArea()
    Local aParam     := PARAMIXB
    Local xRet       := .T.
    Local oObj       := Nil
    Local cIdPonto   := ""
    Local cIdModel   := ""
    Local lIsGrid    := .F.
    Local cMensagem  := ""
    Local nOpc
    Local cAceno     := "\uE41E"
    Local cSorriso   := "\uE056"
    Local cPiscada   := "\uE405"

    //Se tiver par�metros
    If (aParam != Nil)

        //Pega informa��es dos par�metros
        oObj     := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid  := (Len(aParam) > 3)
        nOpc     := oObj:GetOperation()

        //Chamada ap�s a grava��o total do modelo e fora da transa��o
        If (cIdPonto == "MODELCOMMITNTTS")

            //Se for inclus�o
            If nOpc == 3
                //Se tiver o contato, usa ele, do contr�rio, usa o nome reduzido
                If ! Empty(SA2->A2_CONTATO)
                    cNome := Alltrim(SA2->A2_CONTATO)
                Else
                    cNome := Alltrim(SA2->A2_NREDUZ)
                EndIf
                cNome := Capital(cNome)

                //Pega o DDD, e se o usu�rio ter digitado 3 caracteres, retira o primeiro, por exemplo, 014 -> 14
                cDDD := Alltrim(SA2->A2_DDD)
                If Len(cDDD) == 3
                    cDDD := SubStr(cDDD, 2)
                EndIf

                //Pega o Telefone e retira os espa�os
                cTelefone := Alltrim(SA2->A2_TEL)

                //Se tiver DDD e Telefone
                If ! Empty(cDDD) .And. ! Empty(cTelefone)

                    //Monta a mensagem que ser� enviada ao fornecedor
                    cMensagem := 'Ol� <b>' + cNome + '</b> ' + cAceno + '<br>' + CRLF
                    cMensagem += '<br>' + CRLF
                    cMensagem += 'Estamos felizes em fazer neg�cios com voc� e sua empresa ' + cSorriso + '<br>' + CRLF
                    cMensagem += '<br>' + CRLF
                    cMensagem += 'Esperamos atender as expectativas e do que precisar conte com nossa equipe ' + cPiscada + '<br>' + CRLF
                    cMensagem += '<br>' + CRLF
                    cMensagem += 'Atenciosamente,<br>' + CRLF
                    cMensagem += '<br>' + CRLF
                    cMensagem += '<i>Fam�lia Terminal de Informa��o</i>' + CRLF

                    //Faz o envio da mensagem
                    aZap := u_zZapSend("55" + cDDD + cTelefone, cMensagem)

                    //Se houve falha, mostra a mensagem de erro
                    If ! aZap[1]
                        MsgStop(aZap[2], "Falha no envio")
                    EndIf
                EndIf
            EndIf

        EndIf
    EndIf

    RestArea(aArea)
Return xRet

/*/{Protheus.doc} User Function CRMA980
Ponto de Entrada no padr�o MVC acionado no cadastro de Clientes
@type  Function
@author Atilio
@since 06/08/2021
@version version
@see https://centraldeatendimento.totvs.com/hc/pt-br/articles/360016405952-Cross-Segmento-TOTVS-Backoffice-Linha-Protheus-ADVPL-Ponto-de-entrada-MVC-para-as-rotinas-MATA010-MATA020-e-MATA030
@obs A fun��o MATA030 ser� descontinuada em 04/04/2022, ent�o foi usado esse CRMA980 no lugar, veja:
	https://tdn.totvs.com/pages/releaseview.action?pageId=604230458
/*/

User Function CRMA980()
    Local aArea       := GetArea()
    Local aParam      := PARAMIXB
    Local xRet        := .T.
    Local oObj        := Nil
    Local cIdPonto    := ""
    Local cIdModel    := ""
    Local lIsGrid     := .F.
    Local cMensagem   := ""
    Local nOpc
    Local cOculos     := "\uD83D\uDE0E"
    Local cComputador := "\uD83D\uDDA5"
    Local cSacola     := "\uD83D\uDECD"

    //Se tiver par�metros
    If (aParam != Nil)

        //Pega informa��es dos par�metros
        oObj     := aParam[1]
        cIdPonto := aParam[2]
        cIdModel := aParam[3]
        lIsGrid  := (Len(aParam) > 3)
        nOpc     := oObj:GetOperation()

        //Chamada ap�s a grava��o total do modelo e fora da transa��o
        If (cIdPonto == "MODELCOMMITNTTS")

            //Se for inclus�o
            If nOpc == 3
                //Se tiver o contato, usa ele, do contr�rio, usa o nome reduzido
                If ! Empty(SA1->A1_CONTATO)
                    cNome := Alltrim(SA1->A1_CONTATO)
                Else
                    cNome := Alltrim(SA1->A1_NREDUZ)
                EndIf
                cNome := Capital(cNome)

                //Pega o DDD, e se o usu�rio ter digitado 3 caracteres, retira o primeiro, por exemplo, 014 -> 14
                cDDD := Alltrim(SA1->A1_DDD)
                If Len(cDDD) == 3
                    cDDD := SubStr(cDDD, 2)
                EndIf

                //Pega o Telefone e retira os espa�os
                cTelefone := Alltrim(SA1->A1_TEL)

                //Se tiver DDD e Telefone
                If ! Empty(cDDD) .And. ! Empty(cTelefone)

                    //Monta a mensagem que ser� enviada ao cliente
                    cMensagem := 'Ol� <b>' + cNome + '</b> ' + cOculos + '<br>' + CRLF
                    cMensagem += '<br>' + CRLF
                    cMensagem += 'Lhe desejamos as boas vindas, e saiba que do que precisar, pode nos acionar pelo fone <b>(14) 9 9738-5495</b><br>' + CRLF
                    cMensagem += '<br>' + CRLF
                    cMensagem += 'Caso queira dar uma olhada no nosso portfolio, acesse ' + cComputador + ' https://atiliosistemas.com/projetos/<br>' + CRLF
                    cMensagem += '<br>' + CRLF
                    cMensagem += 'Boas compras ' + cSacola + '<br>' + CRLF
                    cMensagem += '<br>' + CRLF
                    cMensagem += 'Atenciosamente,<br>' + CRLF
                    cMensagem += '<br>' + CRLF
                    cMensagem += '<i>Fam�lia Terminal de Informa��o</i>' + CRLF

                    //Faz o envio da mensagem
                    aZap := u_zZapSend("55" + cDDD + cTelefone, cMensagem)

                    //Se houve falha, mostra a mensagem de erro
                    If ! aZap[1]
                        MsgStop(aZap[2], "Falha no envio")
                    EndIf
                EndIf
            EndIf

        EndIf
    EndIf

    RestArea(aArea)
Return xRet
