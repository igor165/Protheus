#Include "Protheus.ch"
#Include "ParmType.ch"

/*/{Protheus.doc} IPAGEN01

Rotina respons�vel pelo retorno da numera��o da tabela

@type 	 function
@author  Ectore Cecato - Totvs IP Jundia�
@since 	 24/04/2017
@version Protheus 12 - Gen�rico

/*/

User function IPAGEN01(cTable, cField)
	
	Local cDoc := ""
	
	cDoc := GetSXENum(cTable, cField)
	
	ConfirmSX8()
	
Return cDoc