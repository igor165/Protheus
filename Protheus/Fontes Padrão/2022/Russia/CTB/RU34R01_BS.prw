#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#include 'RU34R01.ch'

/*/{Protheus.doc} RU34R01
Main function that calls the BP report.
 
 
@author National Platform
@since  13/10/2016
@version 1.0
/*/

Function RU34R01()
Local oRpt

// Calls the quetion RU34R01 to fill the parameters.
If pergunte('RU34R01',.T.)

	DEFINE REPORT oRpt NAME RUSR500 TITLE STR0001 //exclusive
		oRpt:rptParamValue("DDATASIGA", AllTrim(DTOC(MV_PAR09)))
		
	ACTIVATE REPORT oRpt layout RU34R01_BS format HTML
EndIf

Return

//merge branch 12.1.19
// Russia_R5
