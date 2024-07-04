#Include 'UBAW120.CH'
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC

#Define MAX_FILE_LENGTH 600	//Tamanho maximo permitido para o XML gerado (em KB)


/*/{Protheus.doc} UBAW120
//Adapter Setor
@author carlos.augusto
@since 29/06/2018
@version undefined
@type function
/*/
Function UBAW120()

Return 


/*/{Protheus.doc} IntegDef
@author carlos.augusto
@since 29/06/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )
	Local aRet := {}

	If FindFunction("UBAI120")
		aRet:= UBAI120( cXml, nTypeTrans, cTypeMessage )
	EndIf
Return aRet
