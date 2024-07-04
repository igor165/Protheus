#INCLUDE 'PROTHEUS.CH'
/* 

Igor Oliveira

Descri��o:
Localizado na Solicita��o de Compras, este ponto de entrada � respons�vel em validar o registro posicionado da Solicita��o de Compras antes de executar as opera��es de inclus�o, altera��o, exclus�o e c�pia. Se retornar .T., deve executar as opera��es de inclus�o, altera��o, exclus�o e c�pia ou .F. para interromper o processo.

Programa Fonte
mata110.prx

Sintaxe
MT110VLD - Valida o registro na Solicita��o de Compras ( [ ExpN1 ] ) --> ExpL1 

*/
User Function MT110VLD()
    Local nOpc  := Paramixb[1]
    Local lRet := .T.

    if nOpc == 4
        if SC1->C1_APROV == 'L'
            MSGALERT( "Solicita��o n�o pode ser alterada."+CRLF+;
                    ""+CRLF+;
                    "Raz�o: Solicita��o Aprovada.", "Aten��o" )
            lRet := .F.
        endif
    endif
Return lRet


