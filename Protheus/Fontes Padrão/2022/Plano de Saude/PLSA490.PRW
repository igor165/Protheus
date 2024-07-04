#include "PLSMGER.CH"
#include "PROTHEUS.CH"

/*/{Protheus.doc} PLSCarDias
Calcula os dias de acordo com carencia e unidade..
@type function
@author PLSTEAM
@since 07.07.01
@version 1.0
/*/
function PLSCarDias(nCaren,cUnid)
local nDias := 0

//Horas // inclusão do if para tratar uma carência cadastrada em horas
if cUnid == "1"

	nDias := nCaren / 24

//Dia
elseif cUnid == "2" 

	nDias := nCaren

//Mes
elseIf cUnid == "3"  
	
	nDias := 30 * nCaren

//Ano
elseIf cUnid == "4" 
	
	if nCaren > 999
		nCaren := 999
	endIf
	
	nDias := 365 * nCaren
	
endIf     

return(nDias)