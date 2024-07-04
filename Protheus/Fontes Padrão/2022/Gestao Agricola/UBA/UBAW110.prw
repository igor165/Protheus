#Include 'UBAW110.CH'
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

/*/{Protheus.doc} UBAW110
//Retorna Status da Medicao do Contrato - ContractMeasurementStatus-ResultCottonProcessing
@author carlos.augusto
@since 20/06/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Function UBAW110()
	
	/** Deixar esta parte comentada para eventuais testes sem o ambiente PIMS (Protheus x Protheus)
	Processa({|| FWIntegDef( "UBAW110", EAI_MESSAGE_BUSINESS, TRANS_SEND, "", "UBAW110")}, "Simulando Integração do PIMS..." )
	**/

Return 


/*/{Protheus.doc} IntegDef
//Integracao
@author carlos.augusto
@since 20/06/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local aRet := {}

	If FindFunction("UBAI110")
		aRet:= UBAI110( cXml, nTypeTrans, cTypeMessage )
	EndIf
Return aRet
