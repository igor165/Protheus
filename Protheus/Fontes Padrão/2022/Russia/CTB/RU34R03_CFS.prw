#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#include 'RU34R03.ch'

/*
Cash Flow Statement. Отчет о движении денежных средств.
*/
/*/{Protheus.} RU34R03
Cash Flow Statement Report Run
@author National Platform
@since  15/12/2016
@version 1.0
/*/
Function RU34R03()
	Local oRpt
	
	If Pergunte('RU34R03',.T.)
		DEFINE REPORT oRpt NAME RU34R03_CFS TITLE STR0006
		oRpt:rptParamValue("DDATASIGA", AllTrim(DTOC(MV_PAR08)))

		ACTIVATE REPORT oRpt Layout RU34R03_CFS Format HTML
		
	Endif
	
Return

//merge branch 12.1.19
// Russia_R5
