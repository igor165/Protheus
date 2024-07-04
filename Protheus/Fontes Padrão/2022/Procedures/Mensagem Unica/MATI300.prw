#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'
#INCLUDE "FWADAPTEREAI.CH"

/*
{Protheus.doc} MATI300(cXML,nTypeTrans,cTypeMessage,cVersion)
	Atualização do custo do produto                                
		
	@param	cXML      		Conteudo xml para envio/recebimento
	@param nTypeTrans		Tipo de transacao. (Envio/Recebimento)              
	@param	cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
	@param	cVersion		Versão em uso
	
	@retorno aRet			Array contendo o resultado da execucao e a mensagem Xml de retorno.
				aRet[1]	(boolean) Indica o resultado da execução da função
				aRet[2]	(caracter) Mensagem Xml para envio                             
	
	@author	Rodrigo Machado Pontes
	@version	P11
	@since	21/03/2013
*/

Function MATI300(cXML, nTypeTrans, cTypeMessage, cVersion)

Local lRet			:= .T.
Local cXMLRet		:= ""
Local cCustFil	:= SuperGetMV("MV_CUSFIL",.F.,"A")
Local aArea  		:= GetArea()
Local aAreaSB2	:= SB2->(GetArea())

If ( nTypeTrans == TRANS_RECEIVE )
	If	( cTypeMessage == EAI_MESSAGE_WHOIS )
		cXMLRet := '1.000'
	Endif
ElseIf nTypeTrans == TRANS_SEND
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>ItemCosting</Entity>'
	cXMLRet +=     '<Event>upsert</Event>' 
	cXMLRet +=     '<Identification>'
	cXMLRet +=         '<key name="InternalId">' + RTrim(cEmpAnt) + '|' + RTrim(cFilAnt) + '|' + RTrim(SB2->B2_COD) + '</key>'
	cXMLRet +=     '</Identification>'	
	cXMLRet += '</BusinessEvent>'

	cXMLRet += '<BusinessContent>'
		cXMLRet +=	'<CompanyInternalId>' + RTrim(cEmpAnt) + '|' + RTrim(cFilAnt) + '</CompanyInternalId>'
		cXMLRet +=	'<CompanyId>' + RTrim(cEmpAnt) + '</CompanyId>'
		cXMLRet +=	'<ItemCode>' + RTrim(SB2->B2_COD) + '</ItemCode>'
		cXMLRet +=	'<ItemInternalId>' + RTrim(cEmpAnt) + '|' + RTrim(cFilAnt) + '|' + RTrim(SB2->B2_COD) + '</ItemInternalId>'
		cXMLRet +=	'<ListOfSites>'
		cXMLRet += 	'<SiteItemCosting>'
		cXMLRet += 		'<BranchId>' + RTrim(cFilAnt) + '</BranchId>'
		cXMLRet += 		'<WarehouseInternalId>' + RTrim(cEmpAnt) + '|' + RTrim(cFilAnt) + '|' + RTrim(SB2->B2_LOCAL) + '</WarehouseInternalId>'
		cXMLRet +=			'<BatchAverageCosting>'
		cXMLRet +=				'<ListOfBatchAverageCosts>'
		cXMLRet +=					'<UnitValues>'
		If cCustFil == "A" //-- Enviara zero pois a integracao nao admite esta modalidade
			cXMLRet +=						'<MaterialValue>0.0</MaterialValue>'
		Else
			cXMLRet +=						'<MaterialValue>' + RTrim(cValToChar(SB2->B2_VATU1)) + '</MaterialValue>'
		Endif
		cXMLRet +=					'</UnitValues>'
		cXMLRet +=				'</ListOfBatchAverageCosts>'
		cXMLRet +=			'</BatchAverageCosting>'
		cXMLRet +=			'<StandardCosting>'
		cXMLRet +=				'<ListOfStandardCosts>'
		cXMLRet +=					'<UnitValues>'
		If cCustFil == "A" //-- Enviara zero pois a integracao nao admite esta modalidade
			cXMLRet +=						'<MaterialValue>0.0</MaterialValue>'
		Else
			cXMLRet +=						'<MaterialValue>' + RTrim(cValToChar(SB2->B2_CM1)) + '</MaterialValue>'
		Endif
		cXMLRet +=					'</UnitValues>'
		cXMLRet +=				'</ListOfStandardCosts>'
		cXMLRet +=			'</StandardCosting>'
		cXMLRet +=		'</SiteItemCosting>'
		cXMLRet +=	'</ListOfSites>'
	cXMLRet += '</BusinessContent>'
Endif

RestArea(aAreaSB2)
RestArea(aArea)

Return {lRet,cXMLRet}