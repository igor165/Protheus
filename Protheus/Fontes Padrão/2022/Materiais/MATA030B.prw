#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'
#Include "FWAdapterEAI.ch"

//------------------------------------------------------------------------------
/*/{Protheus.doc} MATA030A()
Informação des Clientes, tem a finalidade de verificar atraves do CPF/CNPJ 
se determinado cliente esta cadastrado.                                
@author	Reynaldo Tetsu Miyashita
@version	P12
@since		18/05/2015
/*/
//------------------------------------------------------------------------------
Function MATA030B()

FwIntegDef("MATA030B")
Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} IntegDef(cXML,nTypeTrans,cTypeMessage,cVersion)
Rastreabilidade de pedidos de compra e venda
@param	cXML      		Conteudo xml para envio/recebimento
@param nTypeTrans		Tipo de transacao. (Envio/Recebimento)              
@param	cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
@param	cVersion		Versão em uso
@retorno	aRet		Array contendo o resultado da execucao e a mensagem Xml de retorno.
			aRet[1]	(boolean) Indica o resultado da execução da função
			aRet[2]	(caracter) Mensagem Xml para envio
@author	Reynaldo Tetsu Miyashita
@version	P12
@since		18/05/2015
/*/
//------------------------------------------------------------------------------
Static Function IntegDef( cXML /*cXml*/, nTypeTrans /*cType*/, cTypeMessage /*cTypeMessage*/, cVersion /*cVersion*/, cTransaction /*cTransaction*/)

Local aRet := {}

aRet := MATI030B(cXML, nTypeTrans, cTypeMessage, cVersion, cTransaction)
Return aRet