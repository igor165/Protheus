#Include 'Protheus.ch'
#Include 'tdsBirt.ch'

/*
Autor:			Artem Nikitenko.
Data:			11/10/17
Description: Function for report SB print form
*/

Function RU09T04Rep()
Local oRpt as object

pergunte("RU09T04",.t.)

DEFINE REPORT oRpt NAME RU09T04_SB TITLE 'SB'

ACTIVATE REPORT oRpt

Return Nil
// Russia_R5
