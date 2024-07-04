#Include 'PROTHEUS.CH'
#Include 'OGI020.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

Function OGI020()
Return .T.

/*/{Protheus.doc} IntegDef
//Envio de Fixacao
@author carlos.augusto
@since 28/08/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet 		:= {}	
	/* função descontinuada */
Return aRet
