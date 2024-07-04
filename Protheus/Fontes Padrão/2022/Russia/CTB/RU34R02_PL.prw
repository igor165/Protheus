#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#include "RU34R02.ch"

/*/{Protheus.doc} RU34R02
Main function that calls the P&L report.


@author National Platform
@since  13/10/2016
@version 1.0
/*/

Function RU34R02()
Local oRpt

// Calls the quetion RUSR510 to fill the parameters.
If Pergunte('RU34R02',.T.)
	DEFINE REPORT oRpt NAME RUSR510 TITLE STR0001
	 	oRpt:rptParamValue("DDATASIGA", AllTrim(DTOC(MV_PAR08)))

	ACTIVATE REPORT oRpt Layout RU34R02_PL Format HTML
Endif 

Return


//merge branch 12.1.19
// Russia_R5
