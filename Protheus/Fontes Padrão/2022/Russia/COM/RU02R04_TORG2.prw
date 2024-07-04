#Include 'Protheus.ch'
#Include 'tdsBirt.ch'
#include "RU02R04.CH"

/*
Autor:			Artem Nikitenko
Data:			20/03/18
Description: Function for report TORG-2 print form
*/

Function RU02R04()
	Local oRpt as object

	DEFINE REPORT oRpt NAME RU02R04_TORG2 TITLE STR0001

	ACTIVATE REPORT oRpt

Return Nil

//Update for patch
// Russia_R5
