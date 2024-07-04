#Include "Protheus.ch"
#include "TopConn.ch"
#include "RwMake.ch"
#include "TbIconn.ch"
#Include "FwAdapterEAI.ch"

#Define OK 1
#Define ERROR 2

Function INTXATU01()

Return

/*/{Protheus.doc} Integdef
Mensagem única responsável pela criação do de/para utilizado pela Mensagem Única TOTVS.
    
@author Mateus Gustavo de Freitas e Silva
@since 18/02/2014
@version P11 R9

@param cXML, caracter, XML da mensagem única para envio/recebimento
@param nTypeTrans, numerico, Tipo de transacao. (0-Recebimento, 1-Envio)
@param cTypeMessage, numerico, Tipo de transação da Mensagem. (20-Business, 21-Response, 22-Receipt)

@return array, Array de duas posições sendo a primeira o resultado do processamento e a segunda o texto de resposta.
/*/
Static Function Integdef(cXml, nTypeTrans, cTypeMessage, cAdpVersao)
   Local aRet := {}


   aRet := INTIATU01(cXml, nTypeTrans, cTypeMessage, cAdpVersao)
Return aRet


