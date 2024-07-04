#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'CTBI012A.CH'
#INCLUDE 'FWADAPTEREAI.CH'
#INCLUDE 'FWMVCDEF.CH'

Static cMessage := 'PeriodGlBalance' //Nome da Mensagem Única

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBI012A
Funcao de integracao com o adapter EAI para envio de saldos contabeis para a PIMS

@param   cXml          Variável com conteúdo XML para envio/recebimento.
@param   cTypeTrans    Tipo de transação (Envio / Recebimento).
@param   cTypeMsg      Tipo de mensagem (Business Type, WhoIs, etc).
@param   cVersion      Versão da mensagem.
@param   cTransac      Nome da transação.

@return  aRet   - (array)   Contém o resultado da execução e a mensagem XML de retorno.
       aRet[1] - (boolean)  Indica o resultado da execução da função
       aRet[2] - (caracter) Mensagem XML para envio

@author	Alvaro Camillo Neto
@since		09/09/2013
@version	MP11.90
@obs

/*/
//-------------------------------------------------------------------
Function CTBI012A(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)

Local cXmlRet    := ''
Local cErroXml   := ''
Local cWarnXml   := ''
Local lRet       := .T.
Local oModel     as object
Local oModelCTG  as object
Local oXmlCTB012 as object
 
If lRet
	If cTypeTrans == TRANS_SEND
		oModel := FWModelActive()
		If !IsIncallStack("Ctb010Grava") .or. ( oModel != nil .and. oModel:GetOperation() == MODEL_OPERATION_DELETE) 
			oModelCTG := oModel:GetModel("CTGDETAIL")
			cXml := CT012Xml(oModelCTG:GetValue("CTG_DTINI"), oModelCTG:GetValue("CTG_DTFIM"))
		EndIf
		cXMLRet := cXml

	ElseIf cTypeTrans == TRANS_RECEIVE
		If cTypeMsg == EAI_MESSAGE_WHOIS // Informação das versões compatíveis com a mensagem única.
			cXMLRet := '1.000|2.000'

		ElseIf cTypeMsg == EAI_MESSAGE_RESPONSE // EAI_MESSAGE_RESPONSE == resposta de uma BUSINESS_MESSAGE
			oXmlCTB012 := XmlParser(cXml, "_", @cErroXml, @cWarnXml)
			If !(oXmlCTB012 <> Nil .And. Empty(cErroXml) .And. Empty(cWarnXml))
				lRet    := .F.
				cXMLRet := '<Message type="ERROR" code="c2">' + _NoTags(STR0001) + " " + _NoTags(cErroXml) + ' | ' + _NoTags(cWarnXml) + '</Message>'//'Erro na leitura do XML'
			EndIf
		EndIf
	EndIf
EndIf

Return { lRet, cXmlRet, cMessage }
