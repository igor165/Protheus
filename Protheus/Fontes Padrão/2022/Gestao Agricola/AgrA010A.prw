#INCLUDE "AGRA010.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


/*/{Protheus.doc} AGRA010A
//Integracao Variedade do Talhao
@author carlos.augusto
@since 29/06/2018
@version undefined
@type function
/*/
Function AGRA010A()

Return .T.

/*/{Protheus.doc} IntegDef
//Integracao de Variedades do Talhao
@author carlos.augusto
@since 12/01/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local aRet := {}
	
	If FindFunction("AGRI010A")
		//a funcao integdef original foi transferida para o fonte AGRI010A, conforme novas regras de mensagem unica.
		aRet:= AGRI010A( cXml, nTypeTrans, cTypeMessage )
	EndIf
Return aRet