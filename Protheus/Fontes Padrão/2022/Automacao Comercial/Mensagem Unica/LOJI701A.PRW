#INCLUDE "TOTVS.CH"
#Include 'RwMake.ch'
#Include 'TopConn.ch'
#Include "FWAdapterEAI.ch"

/*
{Protheus.doc} LOJI701A()
    Envia confirmação de pedido pendente
    @author    Julio.Nery
    @version    P12
    @since    17/08/2020
*/

Function LOJI701A()

FwIntegDef("LOJI701A")

Return

/*
{Protheus.doc} IntegDef(cXML,nTypeTrans,cTypeMessage,cVersion)
    Envia confirmação de pedido pendente
    @param    cXML              Conteudo xml para envio/recebimento
    @param nTypeTrans        Tipo de transacao. (Envio/Recebimento)              
    @param    cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
    @param    cVersion        Versão em uso
    
    @retorno aRet            Array contendo o resultado da execucao e a mensagem Xml de retorno.
                aRet[1]    (boolean) Indica o resultado da execução da função
                aRet[2]    (caracter) Mensagem Xml para envio                             
    
    @author    Rodrigo Machado Pontes
    @version    P11
    @since    17/03/2013
*/
Static Function IntegDef(xEnt, nTypeTrans, cTypeMessage, cVersion, cTransaction, lJSon)

    Local aRet        := {.F., "", "DOCUMENTTRACEABILITYORDERRETAIL", "JSON"}
    Local lLOJI701ABO := ExistFunc("LOJI701ABO")

    Default cTransaction := ""

    If lLOJI701ABO
        LjGrvLog("LOJI701A","Antes da Chamada de LOJI701ABO para geração do rastreio")
        aRet := LOJI701ABO(xEnt, nTypeTrans, cTypeMessage, cVersion, lJSon)
        LjGrvLog("LOJI701A","Depois da Chamada de LOJI701ABO para geração do rastreio")
    Else
        aRet[1] := .F.
        aRet[2] := "Função LojI701aBo não encontrada no RPO."
        LjGrvLog("LOJI701A", aRet[2])
    EndIf

Return aRet