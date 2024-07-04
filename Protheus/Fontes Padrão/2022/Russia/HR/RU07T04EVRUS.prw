#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07T04.CH"

//-------------------------------------------------------------------
/*{Protheus.doc} RU07T04EventRUS
@type class
@author D. Tereshenko
@since 11/27/2018
@version 1.0
@project MA3 - Russia
@description Class to handle business procces of RU07T04RUS
*/
Class RU07T04EventRUS From FwModelEvent
	Method New() CONSTRUCTOR
	Method GridLinePreVld()
	Method GridLinePosVld()
				
EndClass

//-------------------------------------------------------------------
/*{Protheus.doc} RU07T04EventRUS
@type method
@author D. Tereshenko 
@since 11/27/2018
@version 1.0
@project MA3 - Russia
@description Basic constructor
*/
Method New() Class RU07T04EventRUS
Return


//-------------------------------------------------------------------
/*{Protheus.doc} RU07T04EventRUS
@type method
@author D. Tereshenko 
@since 11/27/2018
@version 1.0
@project MA3 - Russia
@description Grid Line pre-validation
*/
Method GridLinePreVld(oSubModel, cModelID, nLine, cAction, cId, xValue, xCurrentValue) Class RU07T04EventRUS
	Local aArea As Array
	Local oModelF5F As Object
	Local dDateStart As Date
	Local dDateEnd As Date
	Local dDtStrtExst As Date
	Local dDtEndExst As Date
	Local dDateCnt As Date
	Local cEmplId As Char //RA_MAT
	Local nAttCode As Numeric
	Local nCnt As Numeric
	Local lResult As Logical

	oModelF5F := oSubModel
	lResult := .T.

	If cAction == "SETVALUE" .And. cId == "F5F_ATT"

		nAttCode := Val(xValue)
		If !(nAttCode >= 0 .And. nAttCode <= 99)
			Help(,,STR0020,,STR0017,1,0)
			lResult := .F.
		EndIf

		aArea := GetArea()
		DbSelectArea("SP9")
		SP9->(DbSetOrder(1))

		If !(SP9->(DbSeek(xFilial("SP9") + xValue)))
			Help(,,STR0020,,STR0018,1,0)
			lResult := .F.
		EndIf

		RestArea(aArea)

	EndIf

	If cAction == "SETVALUE" .And. cId $ "F5F_DTSTAR|F5F_DTEND"

		If Empty(xValue)
			Help(,,STR0020,,STR0019,1,0)
			lResult := .F.
		EndIf

		cAttSeq := oModelF5F:GetValue("F5F_SEQ")
		cEmplId := SRA->RA_MAT

		If cId == "F5F_DTSTAR"
			dDateStart := xValue
			dDateEnd := oModelF5F:GetValue("F5F_DTEND")
		ElseIf cId == "F5F_DTEND"
			dDateEnd := xValue
			dDateStart := oModelF5F:GetValue("F5F_DTSTAR")
		EndIf

		If Empty(dDateEnd) .And. !Empty(dDateStart)
			dDateEnd := dDateStart
		ElseIf !Empty(dDateEnd) .And. Empty(dDateStart)
			dDateStart := dDateEnd
		EndIf

		If !Empty(dDateStart) .And. !Empty(dDateEnd)

			// Check if there are existing absenses at specified dates
			aArea := GetArea()
			dbSelectArea("SR8")
			SR8->(DbSetOrder(6))

			For dDateCnt := dDateStart To dDateEnd
				If SR8->(DbSeek(xFilial("SR8") + cEmplId + DTOS(dDateCnt)))
					Help(,,STR0020,,STR0013,1,0)
					lResult := .F.
					Exit
				EndIf
			Next

			RestArea(aArea)

			// Check if there are existing attendances at specified dates
			For nCnt := 1 to oModelF5F:Length()
				If nCnt == nLine
					Loop
				EndIf
    			oModelF5F:GoLine(nCnt)
				dDtStrtExst := oModelF5F:GetValue("F5F_DTSTAR")
				dDtEndExst := oModelF5F:GetValue("F5F_DTEND")

				If (dDateEnd >= dDtStrtExst .And. dDateEnd <= dDtEndExst) .Or. ;
						(dDateStart >= dDtStrtExst .And. dDateStart <= dDtEndExst) .Or. ;
						(dDateStart >= dDtStrtExst .And. dDateEnd <= dDtEndExst) .Or. ;
						(dDateStart <= dDtStrtExst .And. dDateEnd >= dDtEndExst)

					Help(,,STR0020,,STR0014,1,0)
					lResult := .F.
					Exit
				EndIf
			Next
			oModelF5F:GoLine(nLine)
		EndIf
	EndIf

Return lResult


//-------------------------------------------------------------------
/*{Protheus.doc} RU07T04EventRUS
@type method
@author D. Tereshenko 
@since 11/27/2018
@version 1.0
@project MA3 - Russia
@description Grid Line post-validation  
*/
Method GridLinePosVld(oSubModel, cModelId) Class RU07T04EventRUS
	Local aArea As Array
	Local oModelF5F As Object
	Local dDateStart As Date
	Local dDateEnd As Date
	Local dAdmDate As Date
	Local cAttCode As Char
	Local cWorkShift As Char //RA_TNOTRAB
	Local cWkTimeSeq As Char //RA_SEQTURN
	Local cCheckDate As Char
	Local cAttSeq As Char
	Local nAttDays As Numeric
	Local nAttMin As Numeric
	Local nAttMax As Numeric
	Local lResult As Logical

	oModelF5F := oSubModel
	lResult := .T.

	If oModelF5F:IsDeleted(oModelF5F:GetLine()) == .F.

		dDateStart := oModelF5F:GetValue("F5F_DTSTAR")
		dDateEnd := oModelF5F:GetValue("F5F_DTEND")
		cAttCode := oModelF5F:GetValue("F5F_ATT")
		cAttSeq :=  oModelF5F:GetValue("F5F_SEQ")

		dAdmDate := SRA->RA_ADMISSA
		cWorkShift := SRA->RA_TNOTRAB
		cWkTimeSeq := SRA->RA_SEQTURN

		cCheckDate := Posicione("SP9", 1, xFilial("SP9") + cAttCode, "P9_DTCHK")

		nAttDays := 0

		// Validate date of attendance according to P9_DTCHK - user cannot input an Attendance on a working day
		// 1=Start Work; 2=End Work; 3=Both; 4=Neither
		Do Case
			Case cCheckDate == "1"
				If RU07T0407(cWorkShift, cWkTimeSeq, dDateStart)
					Help(,,STR0020,,STR0008,1,0)
					lResult := .F.
				EndIF
			Case cCheckDate == "2"
				If RU07T0407(cWorkShift, cWkTimeSeq, dDateEnd)
					Help(,,STR0020,,STR0009,1,0)
					lResult := .F.
				EndIF
			Case cCheckDate == "3"
				If RU07T0407(cWorkShift, cWkTimeSeq, dDateStart) .And. RU07T0407(cWorkShift, cWkTimeSeq, dDateEnd)
					Help(,,STR0020,,STR0010,1,0)
					lResult := .F.
				EndIF
			Case cCheckDate == "4"
				lResult := .T.
			Otherwise
				lResult := .F.
		End Case


		// Validate duration of attendance in days - between P9_MIN and P9_MAX
		If !Empty(dDateStart) .And. !Empty(dDateEnd)
			nAttDays := dDateEnd - dDateStart + 1
		Else
			Help(,,STR0020,,STR0011,1,0)
			lResult := .F.
		EndIf

		aArea := GetArea()
		DbSelectArea("SP9")
		SP9->(DbSetOrder(1))

		If SP9->(DbSeek(xFilial("SP9") + cAttCode))
			nAttMin := SP9->P9_MIN
			nAttMax := SP9->P9_MAX
			If !(nAttDays >= nAttMin .And. nAttDays <= nAttMax)
				Help(,,STR0020,,STR0012,1,0)
				lResult := .F.
			EndIf
		Else
			lResult := .F.
		EndIf

		RestArea(aArea)

		/*
		- Attendance End Date can not be lower than Attendance Date
		- Attendance Start Date can not be lower than employee’s admission date
		TODO: - Can not be possible to include a new entry for a inactive employee (RA_MSQLBL = 2)
		*/
		If dDateEnd < dDateStart
			Help(,,STR0020,,STR0015,1,0)
			lResult := .F.
		EndIf

		If dDateStart < dAdmDate
			Help(,,STR0020,,STR0016,1,0)
			lResult := .F.
		EndIf

	EndIf

Return lResult
