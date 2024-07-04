#Include 'Protheus.ch'
#Include 'tdsBirt.ch'

/*
Autor:			Artem Nikitenko.
Data:			09/04/18
Description: Function for report PB print form
*/

Function RU09T05Rep()
Local oRpt as object

pergunte("RU09T05",.t.)

DEFINE REPORT oRpt NAME RU09T05_PB TITLE 'PB'

ACTIVATE REPORT oRpt

Return Nil
// Russia_R5
