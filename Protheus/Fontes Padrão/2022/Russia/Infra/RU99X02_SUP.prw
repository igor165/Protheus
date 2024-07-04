#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "RU99X02_SU.CH"
//In this source it is planned to place all the functions that will not be involved in the "query engine". 
/*
#DEFINE STR0001		"Write-off"
#DEFINE STR0002		"Substitution"
#DEFINE STR0003		"Transfer from"
#DEFINE STR0004		"Transfer to"
#DEFINE STR0005		"Implementation"
#DEFINE STR0006		"Depreciation"
#DEFINE STR0007		"Correction"
#DEFINE STR0008		"Depreciation correction"
#DEFINE STR0009		"Enlargement"
#DEFINE STR0010		"Accelerated depreciation"
#DEFINE STR0011		"Negative depreciation"
#DEFINE STR0012		"Positive depreciation"
#DEFINE STR0013		"Inventory"
#DEFINE STR0014		"Write-off by transfer"
#DEFINE STR0015		"Acquisition by transfer"
#DEFINE STR0016		"Accum.depr. for monthly exch.adjust."
#DEFINE STR0017		"Management depreciation"
#DEFINE STR0018		"Putting into operation"
#DEFINE STR0019		"Modernization"
#DEFINE STR0020		"Reevaluation"
#DEFINE STR0021		"Creating Temporary Table"
#DEFINE STR0022		"Select One or More Occurrences"
#DEFINE STR0023		"Occurrence" //checked
#DEFINE STR0024		"Description" //checked
#DEFINE STR0025		"Confirm"
*/

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function WhatSepare( cText )
Local cFoundedSep as character

cFoundedSep := '' 
 
Do Case
	Case ',' $ cText
		cFoundedSep	:= ','
	Case '/' $ cText
		cFoundedSep	:= '/'
	Case '\' $ cText
		cFoundedSep	:= '\'
	Case '|' $ cText
		cFoundedSep	:= '|'
	Case '*' $ cText
		cFoundedSep	:= '*'
	Case '#' $ cText
		cFoundedSep	:= '#'
	Case ';' $ cText
		cFoundedSep	:= ';'
End Case

Return cFoundedSep

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description 
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function FAGetOccor(cOcorr as character)

Local cRet as character

Do Case
	Case cOcorr == "01"
		cRet := STR0001
	Case cOcorr == "02"
		cRet := STR0002
	Case cOcorr == "03"
		cRet := STR0003
	Case cOcorr == "04"
		cRet := STR0004
	Case cOcorr == "05"
		cRet := STR0005
	Case cOcorr == "06"
		cRet := STR0006
	Case cOcorr == "07"
		cRet := STR0007
	Case cOcorr == "08"
		cRet := STR0008
	Case cOcorr == "09"
		cRet := STR0009
	Case cOcorr == "10"
		cRet := STR0010
	Case cOcorr == "11"
		cRet := STR0011
	Case cOcorr == "12"
		cRet := STR0012
	Case cOcorr == "13"
		cRet := STR0013
	Case cOcorr == "15"
		cRet := STR0014
	Case cOcorr == "16"
		cRet := STR0015
	Case cOcorr == "18"
		cRet := STR0016
	Case cOcorr == "20"
		cRet := STR0017
	Case cOcorr == "61"
		cRet := STR0018
	Case cOcorr == "62"
		cRet := STR0019
	Case cOcorr == "63"
		cRet := STR0020
EndCase

Return cRet

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function FAGetAllOccor()

Local aRet as array

aRet := {}

aAdd(aRet, {"01",STR0001})
aAdd(aRet, {"02",STR0002})
aAdd(aRet, {"03",STR0003})
aAdd(aRet, {"04",STR0004})
aAdd(aRet, {"05",STR0005})
aAdd(aRet, {"06",STR0006})
aAdd(aRet, {"07",STR0007})
aAdd(aRet, {"08",STR0008})
aAdd(aRet, {"09",STR0009})
aAdd(aRet, {"10",STR0010})
aAdd(aRet, {"11",STR0011})
aAdd(aRet, {"12",STR0012})
aAdd(aRet, {"13",STR0013})
aAdd(aRet, {"15",STR0014})
aAdd(aRet, {"16",STR0015})
aAdd(aRet, {"18",STR0016})
aAdd(aRet, {"20",STR0017})
aAdd(aRet, {"61",STR0018})
aAdd(aRet, {"62",STR0019})
aAdd(aRet, {"63",STR0020})

Return aRet


STATIC aFldBrw as array

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description Get all N4_OCORR codes as necessary
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function GetN4_OCORR()
Local aCores	as array
Local cInitValue as character
Private cMark as character

Private aRotina 	:= {}
Private cCadastro	:= STR0022
Private bRet 		:= .T.
Private bOpc1 		:= {|| FAMarkAllOccor()}
Private bOpc2 		:= {|| FAMarkLine()}

aFldBrw			:= {}
aCores    		:= {}
aRotina			:= {{STR0025 ,"CloseBrowse()" , 0 , 2 }}
cMark			:= FAGetMarkOccor()
cOccTempFile	:= GetOccTmpDB()
 
If Select(cOccTempFile) == 0
	cInitValue	:= Alltrim( MV_PAR05 )
	Processa({|| OccorTmpDB(cInitValue)},STR0021)	
Endif

MarkBrow( cOccTempFile , 'N4_OK',,aFldBrw,, cMark ,"Eval(bOpc1)"   ,,,,"Eval(bOpc2)"   ,,,.T.,aCores,,,,.F.) //FWMARKBROWSE

FAReturnOccor()

Return bRet

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description Create temporary table
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function OccorTmpDB(cInitValue as character)
Local aStruct	as array
Local aCampos	as array
Local aOcorr	as array
Local nCount	as numeric
Local lInit		as logical
       
Default cInitValue := ""

lInit	:= !Empty(cInitValue)
aStruct	:= {}
aCampos	:= {}
aOcorr	:= {}

ProcRegua(0)

aFldBrw	:= {}
aCampos	:= {}

AADD(aFldBrw,	{"N4_OK"	, , "Mark", ""})
AADD(aFldBrw,	{"N4_OCORR"	, , STR0023, ""})
AADD(aFldBrw,	{"N4_DESC"	, , STR0024, ""})

AADD(aStruct,	{"N4_OK", "C", 2, 0})
AADD(aStruct,	{"N4_OCORR", 'C', 2, 0})
AADD(aStruct,	{"N4_DESC", 'C', 20, 0})

cOccTempFile :=	Criatrab(,.F.)

oOccorTmpTable := FWTemporaryTable():New( cOccTempFile )
oOccorTmpTable:SetFields( aStruct )
oOccorTmpTable:Create()

aOcorr := FAGetAllOccor()

For nCount:=1 to Len(aOcorr)
	
	RecLock(cOccTempFile , .T.)
		
		If lInit
			( cOccTempFile )->(N4_OK)	:= Iif( aOcorr[nCount][1] $ cInitValue , cMark , '  ' )
		Else
			( cOccTempFile )->(N4_OK)	:= '  '
		Endif
		
		( cOccTempFile )->(N4_OCORR) 	:= aOcorr[nCount][1]
		( cOccTempFile )->(N4_DESC) 	:= aOcorr[nCount][2]
	MsUnlock()

Next nCount

Return Len(aOcorr)

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description Check or Uncheck all items
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function FAMarkAllOccor()

	DbSelectArea(cOccTempFile)
	DbGoTop()
	Do While !(cOccTempFile)->(EOF())
		FAMarkLine()
	
		(cOccTempFile)->( DbSkip() )
	EndDo

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description Check or uncheck unique item/line
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function FAMarkLine()

	If IsMark("N4_OK",cMark )
		RecLock(cOccTempFile,.F.)
			(cOccTempFile)->N4_OK := ""
		(cOccTempFile)->( MsUnLock() ) 
	Else
		RecLock(cOccTempFile,.F.)
			(cOccTempFile)->N4_OK := cMark
 		(cOccTempFile)->( MsUnLock() )
	EndIf

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description String - All N4_OCCOR types concatenated
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function FAReturnOccor()

cOccList := ''

DbSelectArea(cOccTempFile)
DbGoTop()
Do While !(cOccTempFile)->(EOF())

	If IsMark("N4_OK",cMark )
		cOccList += (cOccTempFile)->(N4_OCORR) + '|'
	Endif

	(cOccTempFile)->( DbSkip() )
EndDo

MV_PAR05 := cOccList
SetMVValue("ATFREP","MV_PAR05",MV_PAR05)
//FWmodelactiv
Return cOccList