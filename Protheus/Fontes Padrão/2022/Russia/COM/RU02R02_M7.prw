#Include 'Protheus.ch'
#Include 'tdsBirt.ch'

/*
Autor:			Anastasiya Kulagina
Data:			13/11/17
Description: Function for report M-7 print form
*/

Function RU02R02()
	Local oRpt as object
	Local cAliasTM2 as Char
	Local aArea2 as array
	
	aArea2 := getArea()
	cAliasTM2	:= GetNextAlias()

	DEFINE REPORT oRpt NAME RU02R02_M7 TITLE "M-7"

	ACTIVATE REPORT oRpt

Return Nil
// Russia_R5
