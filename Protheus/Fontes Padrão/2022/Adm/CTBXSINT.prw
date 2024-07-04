#Include 'Protheus.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBXSINT
Funcao de integracao do tipo Request para saldo contábeis.

@author  Alvaro Camillo Neto
@version P12.1.8
@since   14/09/2015

/*/
//------------------------------------------------------------------------------------
Function CTBXSINT()
	FwIntegDef( 'CTBXSINT', , , , 'CTBXSINT' )
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Função para a interação com EAI

@author  Alvaro Camillo Neto
@version P12.1.8
@since   14/09/2015

/*/
//------------------------------------------------------------------------------------
STATIC FUNCTION IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
	Local aRet := {}
	aRet:= CTBISAL(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return aRet


