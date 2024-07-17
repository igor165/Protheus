#INCLUDE 'PROTHEUS.CH'
#INCLUDE "RWMAKE.CH"  
#INCLUDE 'AGRAXFUN.CH'
 
/** {Protheus.doc}
Integra com a balan�a e captura o peso 
@author     Fernando Oliveira
@since     11/09/2020
@OBS       � necess�rio o uso de um m�dulo TCP/IP para fazer a convers�o da balan�a serial para IP
@see       www.linkedin.com/in/luis-fernando-oliveira-2b6a40a2
*/
 
User Function BALIP()
Local cPorta    := "3030"
Local cIPServer := '192.168.0.170'
Local cTimeOut  := '1000'
Local cScript   := 'Substr(cConteudo,at(Chr(002) ,cConteudo)+3,7)'
Local oSocket
Local nSockResp := 0
Local nSockRead := 0
Local cBuffer    := ''
Local nFor01    := 0
Local nRetorno    := 0
Local cConteudo    := ""
 
    oSocket     := tSocketClient():New()       //Criando a Clase
    For nFor01 := 1 to 10
        nSockResp := oSocket:Connect( val(cPorta),Alltrim(cIPServer),Val( cTimeOut ) )
        //Verificamos se a conexao foi efetuada com sucesso
        IF !( oSocket:IsConnected() )  //ntSocketConnected == 0 OK
            Help(,,STR0010,,STR0020 + Chr(10) + Chr(13) +  "[ " + StrZero( nFor01,3 ) + " ]" , 1, 0 )  //"Ajuda"####n�o foi possivel conectar com a balan�a na Porta#
        Else 
            nSockResp == 0   // Conex�o Ok
            Exit
        EndIF
    Next
 
    IF nSockResp == 0 // Indica que Est� conectado // Enviando um Get Para Capturar o Peso
        Sleep (5000)
        For nFor01 := 1 To 10
            cBuffer := ""
            nSockRead = oSocket:Receive( @cBuffer,  Val( cTimeout ) )
            IF( nSockRead > 0 )
                cConteudo := cBuffer
                Exit
            Else
                cConteudo := ''
            Endif
        Next nFor01
    Else
        Help(,,STR0010,,STR0027 + Chr(10) + Chr(13) +  "[ "  + cIpServer + "/" + cPorta + " ]" , 1, 0 )  //"Ajuda"####n�o foi possivel conectar com a balan�a. Tentavia:# ###"Balan�a: "
    EndIF
    oSocket:CloseConnection()   //Fechando a Conex�o1
     
    If .Not. Empty( AllTrim( cScript ) )               // Ir� Aplicar o Script no cConteudo
        cScript := "{||" +  Alltrim(cScript) + "}"  //Transformando o Script em bloco de codigo
        cConteudo := Eval( &( cScript ) )
        nRetorno := Val( cConteudo )
    Else
        nRetorno := 0
    EndIf
 
Return(nRetorno)

User Function TesBCur()
    Local nI 
    Local nRet

    for nI := 1 to 100
        nRet := U_TesBlCur()
        if nRet > 0 
            MSGSTOP("PESO INFORMADO: " + str(nRet))
        endif 
    next
Return


 User Function TesBlCur() //U_TesBlCur()
    Local oObj        := tSocketClient():New()
    Local nX          := 0
    Local nIp         := '192.168.0.128'
    Local nPort       := 80
    Local cBuffer     := ""
    Local xRetorno

    Default lConverte := .T.

    xRetorno          := iIf(lConverte, 0, "0")

    // -------------------------------
    // Tenta conectar 3 vezes
    // -------------------------------
    For nX := 1 to 5
        nResp := oObj:Connect( nPort,nIp,10 )
        if(nResp == 0 )
            exit
        else
            conout("--> Tentativa de Conex�o: " + StrZero(nX,3))
            Sleep(2000)
            // continue
            Alert("Sem conectividade com a balan�a para a coleta do peso, tentativa n� " +cValtoChar(nX)+ ". Esta mensagem aparece quando o sistema solicita o peso para a balan�a e n�o ocore a resposta. Verificar se a balan�a est� ligada e se o cabo de comunica��o est� ok.")
        endif
    Next

    // --------------------------------------
    // Verifica se a conex�o foi bem sucedida
    // --------------------------------------
    if( !oObj:IsConnected() )
        conout("--> Falha na conex�o")
        return xRetorno
    else
        conout("--> Conex�o OK")
    endif

    // -------------------------------
    // Teste de envio para o socket
    // -------------------------------
    cSend := OemToAnsi("Nao precisa ser enviado nada.") // Dados enviados pelo AdvPL..."
    nResp := oObj:Send( cSend )
    if( nResp != len( cSend ) )
        conout( "--> Erro! Dado nao transmitido" )
    else
        conout( "-- > Dado Enviado - Retorno: " +StrZero(nResp,5) )
    endif

    // -------------------------------
    // Teste de recebimento do socket
    // -------------------------------
    nResp = oObj:Receive( @cBuffer, 10000 )
    if( nResp >= 0 )
        conout( "--> Dados Recebidos " + StrZero(nResp,5) )
        conout( "--> ["+cBuffer+"]" )

        If lConverte
            if !Empty(cBuffer)
                cBuffer := SubS(cBuffer, 5, Len(SubS(cBuffer, 5))-1)
                xRetorno    := Val( SubS( cBuffer, 1, 6)+'.'+SubS( cBuffer, 7) )

                If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
                    MemoWrite( "C:\totvs_relatorios\Pesagem_" + AllTrim(cPlacaTGet) + "_" + DtoS(MsDate()) + "_" + StrTran(Time(),":","") + ".txt",;
                        cBuffer+/* CRLF+ */cValToChar(xRetorno) )
                EndIf
            EndIf
        EndIf
    else
        conout( "--> Nao recebi dados" )
    endif

    // -------------------------------
    // Fecha conex�o
    // -------------------------------
    oObj:CloseConnection()
    conout( "--> Conex�o fechada" )

Return xRetorno// Return cBuffer
