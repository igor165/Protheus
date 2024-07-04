#Include 'UBAW130.CH'
#Include 'PROTHEUS.CH'
#Include 'FWADAPTEREAI.CH'	//Include para rotinas de integração com EAI
#Include 'FWMVCDEF.CH' 		//Include para rotinas com MVC


/*/{Protheus.doc} UBAW130
//Adapter para retornar OK em ProductionPeriod
@author carlos.augusto
@since 29/06/2018
@version undefined
@type function
/*/
Function UBAW130()


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

	If FindFunction("UBAI130")
		aRet:= UBAI130( cXml, nTypeTrans, cTypeMessage )
	EndIf
Return aRet
