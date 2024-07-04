#INCLUDE "CTBA040.CH"
#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA040A
Fun��o de integra��o para envio e recebimento do item cont�bil
utilizando o conceito de mensagem �nica.

@author  Diego Rodolfo dos Santos
@version P12.1.8
@since   18/09/2015
/*/
//------------------------------------------------------------------------------------
Function CTBA040A()

Local aEaiRet := {}

aEaiRet := FwIntegDef('CTBA040A',,,,'CTBA040A')
If ValType(aEaiRet) <> "A" .or. len(aEaiRet) < 2
	aEaiRet := {.F., ""}
Endif
If !aEaiRet[1]
	Help(,, "HELP",, AllTrim(aEaiRet[2]), 1, 0,,,,,, {STR0034})  // "Problemas na integra��o EAI. Transa��o n�o executada."
	DisarmTransaction()
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IntegDef
Fun��o para a intera��o com EAI

@author  Diego Rodolfo dos Santos
@version P12.1.8
@since   18/09/2015
/*/
//------------------------------------------------------------------------------------
Static Function IntegDef(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
Return CTBI040A(cXml, cTypeTrans, cTypeMsg, cVersion, cTransac)
