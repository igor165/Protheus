#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#include "RU34R05.ch"

/*/{Protheus.doc} RU34R05
Main function that calls the Report on changes of the capital.
@author Andrey Filatov
@since  28/02/2017
@version 1.0
/*/
Function RU34R05()
	Local oRpt
	
	If Pergunte('RU34R05',.T.)
		DEFINE REPORT oRpt NAME RU34R05_RC TITLE STR0001

		oRpt:rptParamValue("DDATASIGA", AllTrim(DTOC(MV_PAR08)))

	
		ACTIVATE REPORT oRpt Layout RU34R05_RC Format HTML

	Endif
	
Return


//merge branch 12.1.19

// Russia_R5
