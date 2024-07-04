#INCLUDE "LOJATEF.CH"

Static nSlotLTT  := 3022         
Static lTemLTT   := Nil  
Static lSendTMTT := .F.
Static dConsulta := date()
Static cMsgTefNOk:= STR0001         +;           //"Não identificamos a licença para uso do TOTVS TEF em seu ambiente, por esse motivo não será possivel realizar vendas utilizando TEF."
                    CHR(13)+CHR(10) +;
                    CHR(13)+CHR(10) +;
                    CHR(13)+CHR(10) + STR0002   //"*Para que seja possível realizar vendas com cartão manualmente (via POS) e para deixar de exibir esta mensagem, desative o TEF no cadastro de estação."

                     

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjGetLTT
Checa no License Serve se o cliente a licença do TOTVS TEF

@type       Function
@author     Lucas Novais (lnovais@)
@since      12/06/2020
@version    12.1.27

@return Array, Retorna se o cliente tem ou não a licença do TOTVS TEF baseado no conteúdo da variável statica lTemLTT juntamente com  mensagem para ser exibida para o usuario, 
caso já tenha sido consultada nesta Thread não realiza uma próxima consulta até que mude o dia ou a Thread seja reiniciada.
/*/
//-------------------------------------------------------------------------------------------------------

Function LjGetLTT()

IF cPaisLoc == "BRA"
    If lTemLTT == Nil .Or. dConsulta <> date()
        LjSetLTT()
    EndIf 
Else
    LjTMTT("3")
    lTemLTT := .T.
Endif     

Return {lTemLTT,cMsgTefNOk}

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjSetLTT
Checa no License Serve se o cliente a licença do TOTVS TEF

@type       Function
@author     Lucas Novais (lnovais@)
@since      12/06/2020
@version    12.1.27

@return Nill, Nulo
/*/
//-------------------------------------------------------------------------------------------------------

Static Function LjSetLTT()
    dConsulta := Date()
    lTemLTT := .T. //FWLSEnable(nSlotLTT)
Return

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjTMTT
Envia a telemetria para o License Server com o TEF que sendo utilizado pela estação.

@type       Function
@author     Lucas Novais (lnovais@)
@since      12/06/2020
@version    12.1.27

@param cTipoTEF, Caractere, Tipo do TEF Configurado
1 - Sem TEF (Usa POS)
2 - Usa TEF Discao / PayGo 
3 - Usa TEF Dedicado (SiTef))

@return lRetorno, Logico, Retorna indicando que enviou a telemetria
/*/
//-------------------------------------------------------------------------------------------------------

Function LjTMTT(cTipoTEF)
Local lRetorno  := .F.
Local cFunction := ""

Do Case
    Case cTipoTEF == "1" //Sem TEF (Usa POS)
        cFunction := "LJ_TEFPOS"
    Case cTipoTEF == "2" //Usa TEF Discao / PayGo
        cFunction := "LJ_TEFDISC"
    Case cTipoTEF == "3" //Usa TEF Dedicado (SiTef))
        cFunction := "LJ_TEFDED"
EndCase

If !lSendTMTT .And. !Empty(cFunction) 
    FWLsPutAsyncInfo("LS006",,cValToChar(nSlotLTT),cFunction)
    lSendTMTT := .T.  
    lRetorno  := .T.
EndIf

Return lRetorno

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} STGetLTT
Retorna se o cliente tem licença do TOTVS TEF utilizando o Host para comunicação com a retaguarda

@type       Function
@author     Lucas Novais (lnovais@)
@since      12/06/2020
@version    12.1.27

@return Array, Retorna consulta de licença do License serve juntamente com a mensagem a ser exibida
/*/
//-------------------------------------------------------------------------------------------------------

Function STGetLTT()
Local aParams   := {"LjGetLTT"}
Local aRetorno  := array(2)
Local lConn     := .F.  

If lTemLTT == Nil 
    lConn := STBRemoteExecute("STCOMDIR" ,aParams, NIL,.F.	,@aRetorno)
     
    lTemLTT := aRetorno[1]
    // -- Caso não tenha conexão com a retaguarda ou tenha acontecedo algum erro na retaguarda libera o TEF
    If !lConn
        aRetorno[1] := .T.
    EndIf
  
Else
    aRetorno[1] := lTemLTT
    aRetorno[2] := cMsgTefNOk
EndIf

Return aRetorno

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} STTMTT
Envia a telemetria para o License Server (utilizando o HOST) com o TEF que sendo utilizado pela estação.

@type       Function
@author     Lucas Novais (lnovais@)
@since      12/06/2020
@version    12.1.27

@param cTipoTEF, Caractere, Tipo do TEF Configurado
1 - Sem TEF (Usa POS)
2 - Usa TEF Discao / PayGo 
3 - Usa TEF Dedicado (SiTef)

@return lRetorno, Logico, Retorna se conseguiu se comunicar com a retaguarda para executar a função
/*/
//-------------------------------------------------------------------------------------------------------

Function STTMTT(cTipoTEF)
Local lRetorno := .F.
Local oX       := Nil //Na Função STCOMDIR foi modificada para receber um objeto no primeiro parametro
Local aParams   := {oX,"LjTMTT",{cTipoTEF}}
Local lConn     := .F. 

If !lSendTMTT .And. !Empty(cTipoTEF)
    If lConn := STBRemoteExecute("STCOMDIR" ,aParams, NIL,.F.,@lRetorno)
        lSendTMTT := .T.  
    EndIf 
EndIf

Return lRetorno

//-------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LjRetTpTef
Retorna o tipo de TEF convertido, de acordo como está configurado no cadastro de Estacao

@type       Function
@author     Alberto Deviciente
@since      11/06/2020
@version    12.1.27

@param cTipoTEF, Caractere, Tipo do TEF Configurado no cadastro de estação (campo LG_TIPTEF)

@return cRet, Caractere, Tipo de TEF convertido, de acordo como está configurado no cadastro de Estacao
/*/
//-------------------------------------------------------------------------------------------------------
Function LjRetTpTef(cTipoTEF)
Local cRet := ""

Do Case
    Case cTipoTEF == "1" //Sem TEF (Usa POS)
        cRet := "1"
    Case cTipoTEF $ "2|3|4|5" //Usa TEF Discao / PayGo
        cRet := "2"
    Case cTipoTEF == "6" //Usa TEF Dedicado (SiTef))
        cRet := "3"
EndCase

Return cRet
