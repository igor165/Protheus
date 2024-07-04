#Include "Protheus.ch"
#Include "ParmType.ch"

/*/{Protheus.doc} IPAGEN01

Rotina responsável pelo retorno da numeração da tabela

@type 	 function
@author  Ectore Cecato - Totvs IP Jundiaí
@since 	 24/04/2017
@version Protheus 12 - Genérico

/*/

User function IPAGEN01(cTable, cField)
	
	Local cDoc := ""
	
	cDoc := GetSXENum(cTable, cField)
	
	ConfirmSX8()
	
Return cDoc