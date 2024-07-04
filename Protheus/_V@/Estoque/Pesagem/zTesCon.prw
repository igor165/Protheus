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
