#INCLUDE "OGI040.CH"
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

Function OGI040()
Return .T.

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet 		:= {}	
	/* função descontinuada */
Return aRet