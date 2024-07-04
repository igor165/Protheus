#INCLUDE "PROTHEUS.CH"

//------------------------------------------------------------------
/*/{Protheus.doc} TAFLicAbono

Funcao responsavel por retornar as rotinas habilitadas a serem 
executadas pelo módulo 92 - TOTVS Automação Fiscal Light, 
cujo objetivo eh não efetuar consumo de licenca TOTVSTEC
** Esta funcao é chamada pela LIB na execucao da rotina via menu.

@param	Nil

@return aRet	-> Nomes dos programas sem o .PRW

@author Gustavo G. Rueda
@since 02/07/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAFLicAbono()
Local	aRet	as	array

aRet	:=	{}
aAdd(aRet,"TAFLOAD")
aAdd(aRet,"TAFDIAG")
aAdd(aRet,"TAFAWIZD")
aAdd(aRet,"CFGA510")
aAdd(aRet,"CFGA520")
aAdd(aRet,"CFGA530")
aAdd(aRet,"CFGA540")
aAdd(aRet,"CFGA550")
aAdd(aRet,"CFGA560")
aAdd(aRet,"FWCADGRPCO")
aAdd(aRet,"FWCADCOMPA")
aAdd(aRet,"FWCADUNIDN")
aAdd(aRet,"FWCADFILIA")
aAdd(aRet,"TAFA050")
aAdd(aRet,"TAFA099")
aAdd(aRet,"TAFMONTES")
aAdd(aRet,"TAFAEXCPER")
aAdd(aRet,"TAFAINTEG")
aAdd(aRet,"TAFTICKET")
aAdd(aRet,"TAFPNFUNC")
aAdd(aRet,"TAFA441")
aAdd(aRet,"CFGX017")
aAdd(aRet,"CFGA010")
aAdd(aRet,"TAFA051")
aAdd(aRet,"TAFA489")
aAdd(aRet,"TAFA097")
aAdd(aRet,"TAFA298")
aAdd(aRet,"TAFA062E")
aAdd(aRet,"TAFA062S")
aAdd(aRet,"TAFA448")
aAdd(aRet,"TAFA503")
aAdd(aRet,"TAFA494")
aAdd(aRet,"TAFA495")
aAdd(aRet,"TAFA486")
aAdd(aRet,"TAFA478")
aAdd(aRet,"TAFA255")
aAdd(aRet,"TAFA491")
aAdd(aRet,"TAFA492")
aAdd(aRet,"TAFA499")
aAdd(aRet,"TAFA493")
aAdd(aRet,"TAFA502")
aAdd(aRet,"TAFA496")
aAdd(aRet,"TAFA493")
aAdd(aRet,"TAFA490")
aAdd(aRet,"TAFA501")
aAdd(aRet,"TAFA497")
aAdd(aRet,"TAFAPREINF")
aAdd(aRet,"TAFMONREI") 

Return aRet
