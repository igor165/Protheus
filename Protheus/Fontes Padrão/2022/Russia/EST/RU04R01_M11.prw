#Include 'Protheus.ch'
#Include 'tdsBirt.ch'


/*
Autor:			Anastasiya Kulagina
Data:			31/10/17
Description: Function for report M-11 print form
*/

Function RU04R01()

	Local oRpt as object
	Local cAliasTM2 as Char
	Local aArea2 as array
	
	aArea2 := getArea()
	cAliasTM2	:= GetNextAlias()

	DEFINE REPORT oRpt NAME RU04R01_M11 TITLE "M-11"

	ACTIVATE REPORT oRpt

Return Nil
// Russia_R5
