#INCLUDE "OGI040.CH"
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integra��o com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)

Function OGI040()
Return .T.

Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet 		:= {}	
	/* fun��o descontinuada */
Return aRet