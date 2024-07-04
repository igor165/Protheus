#INCLUDE "Protheus.ch"
#INCLUDE "RU07D09.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D09
	Types of Attendance Registration File (Russia)

	@author D. Tereshenko
	@since 11/19/2018
	@version 1.0
	@project MA3 - Russia
/*/
Function RU07D09RUS()
	Local oBrowse As Object

	RU07D09F01()

	oBrowse := BrowseDef()
	oBrowse:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef
	Browse definition

	@author D. Tereshenko
	@since 11/14/2018
	@version 1.0
	@project MA3 - Russia
/*/
Static Function BrowseDef()
	Local oBrowse As Object

	oBrowse := FWLoadBrw("RU07D09")

Return oBrowse 

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
	Model definition

	@author D. Tereshenko
	@since 11/14/2018
	@version 1.0
	@project MA3 - Russia
/*/
Static Function ModelDef()
	Local oModel As Object
		
	oModel := FwLoadModel("RU07D09")

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
	View definition

	@author D. Tereshenko
	@since 11/14/2018
	@version 1.0
	@project MA3 - Russia
/*/
Static Function ViewDef()
	Local oModel As Object
	Local oView As Object
		
	oView := FWLoadView("RU07D09")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
	Menu definition

	@author D. Tereshenko
	@since 11/14/2018
	@version 1.0
	@project MA3 - Russia
/*/
Static Function MenuDef()

	Local aRotina := FWLoadMenuDef("RU07D09")

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D09F01
	@description Function calls autofilling of Attendance Types in case when table SP9 is empty

	@author D. Tereshenko
	@since 11/16/2018
	@version 1.0
	@project MA3 - Russia
/*/
Function RU07D09F01()
	Local cAttCode As Char
	Local cFilSP9 As Char
	Local nCnt As Numeric
	Local aArea As Array

	cAttCode := SP9->P9_CODIGO
	cFilSP9 := xFilial("SP9")
	nCnt := 0

	aArea := GetArea()

	DbSelectArea("SP9")
	DbSetOrder(1)
	DbSeek(xFilial("SP9") + cAttCode)

	While !Eof() .and. cFilSP9 + cAttCode = SP9->P9_FILIAL + SP9->P9_CODIGO
		nCnt++
		DbSkip()
	Enddo 

	RestArea(aArea)

	If nCnt == 0
		RU07D09F02()
	Endif

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} RU07D09F02
	Function for automatically loading data about Attendance Types

	@author D. Tereshenko
	@since 11/16/2018
	@version 1.0
	@project MA3 - Russia
/*/
Function RU07D09F02()
	Local aArea As Array
	Local aFldSP9 As Array
	Local aDataSP9 As Array
	Local nX as Numeric
	Local nY as Numeric
	Local lOK as Logical
	Local oModelSP9	as Object

	aFldSP9 := {"P9_CODIGO", "P9_DESC", "P9_MIN", "P9_MAX", "P9_DTCHK"}
	aDataSP9 := {}
			
	aAdd(aDataSP9, {"001", STR0010, 0, 999, "4"}) // "Overtime"
	aAdd(aDataSP9, {"002", STR0011, 0, 999, "3"}) // "Work on weekend / holiday payment"
	aAdd(aDataSP9, {"003", STR0012, 0, 999, "3"}) // "Work on weekends / holidays off time"
	aAdd(aDataSP9, {"004", STR0013, 0, 999, "4"}) // "Work in VUT"

	aArea := GetArea()
	DbSelectArea("SP9")
	oModelSP9 := FwLoadModel("RU07D09")
	oModelSP9:SetOperation(MODEL_OPERATION_INSERT)
	lOK := .T.

	Begin Transaction

		For nX := 1 to Len(aDataSP9)

			SP9->(DbSetOrder(1))

			If !SP9->(DbSeek(xFilial("SP9") + aDataSP9[nX,1]))

				oModelSP9:Activate()

				For	nY := 1	to Len(aFldSP9)

					// Change stuff
					lOK	:= lOK .And. oModelSP9:GetModel("RU07D09_MSP9"):SetValue(aFldSP9[nY], aDataSP9[nX,nY])

				Next nY

				FWFormCommit(oModelSP9)
				oModelSP9:Deactivate()

				If !lOK
					Help(,,STR0008,,STR0007,1,0)
				EndIf

			EndIf

		Next nX
		
	End Transaction

	RestArea(aArea)
	
Return .T.