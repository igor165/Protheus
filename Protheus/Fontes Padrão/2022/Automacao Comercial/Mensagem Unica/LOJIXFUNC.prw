#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "TBICONN.CH" 
#INCLUDE "TbiCode.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} LOJIXFUNC

Funcao de integracao com o adapter EAI para envio/recebimento de Vendas Varejo utilizando o conceito
Mensagem Unica.

@param   cXml        	Variável com conteúdo XML para envio/recebimento.
@param   nTypeTrans  	Tipo de transação. (Envio/Recebimento)
@param   cTypeMsg  		Tipo de mensagem. (Business Type, WhoIs, etc)

@author  Everson S. P. Junior 
@version P12
@since   17/12/2018
@return  lRet - (boolean)  Indica o resultado da execução da função
          cXmlRet - (caracter) Mensagem XML para envio
          Nome do Adapter EAI
/*/
//-------------------------------------------------------------------------------------------------
Function LOJIXFUNC(cXml, nTypeTrans, cTypeMsg,lJSon)
Local cXmlRet	  := ""  //Mensagem de retorno da integracao
Local lRet		  := .T. //Retorno da integracao
Local lCancVen    := .F. //Flag cancelamento de venda
Local oXmlLXFC    := Nil
Local cDestinaId  := Alltrim(cEmpAnt) + '|' + Alltrim(cFilAnt) + '|'+Alltrim(SL1->L1_SERIE) +'|'+Alltrim(SL1->L1_DOC) +'|'+Alltrim(SL1->L1_PDV)

Default cXml	  := "" 	
Default lJSon 	  := .F.

If nTypeTrans == TRANS_SEND
	//ConOut("LOJIXFUNC: Dentro do TRANS_SEND ")
	cEvent   := "upsert" //Evento
	If !lCancVen
		//ConOut("LOJIXFUNC: Gernado XML ")
		cXmlRet := '<BusinessEvent>'
		cXmlRet +=     '<Entity>DocumentTraceabilityRetailSales</Entity>'
		cXmlRet +=     '<Event>' + cEvent + '</Event>'
		cXmlRet +=     '<Identification>'
		cXmlRet +=         '<key name="InternalId">' + cDestinaId + '</key>'
		cXmlRet +=     '</Identification>'
		cXmlRet += '</BusinessEvent>'
		cXmlRet += '<BusinessContent>'
		cXmlRet +=    '<InternalId>' + cDestinaId + '</InternalId>'
		cXmlRet +=    '<CompanyInternalId>' + cEmpAnt + '|' + cFilAnt+'</CompanyInternalId>'
		cXmlRet +=    '<CompanyId>' + cEmpAnt + '</CompanyId>'
		cXmlRet +=    '<BranchId>' + cFilAnt + '</BranchId>'
		cXmlRet +=    '<Number>'+SL1->L1_NUM+'</Number>'
		cXmlRet +=    '<Status>' + CValToChar(SL1->L1_SITUA) + '</Status>'
		cXmlRet +=    '<Detail>' +cXml+ '</Detail>'
		cXmlRet += '</BusinessContent>'
		//ConOut(cXmlRet)
	EndIf
ElseIf cTypeMsg == EAI_MESSAGE_WHOIS
	cXmlRet := "1.000|1.001|1.002|2.000|2.001|2.002|2.003|2.004|2.005|2.006"
EndIf
//Limpar os objetos após à execução do adapter
freeobj(oXmlLXFC)
Return {lRet, cXmlRet, "DocumentTraceabilityRetailSales"}