#INCLUDE "Protheus.ch"
#INCLUDE "RU07T04.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T04
Types of Attendance Registration File 

@author D. Tereshenko
@since 11/14/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T04()
	Local oBrowse As Object

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

	oBrowse	:= FWmBrowse():New()
	oBrowse:SetAlias("SRA")
	oBrowse:SetDescription(STR0001)  
	oBrowse:AddLegend("RA_MSBLQL == '2'", "GREEN", STR0006)
	oBrowse:AddLegend("RA_MSBLQL == '1'", "RED", STR0007)
	oBrowse:DisableDetails()
	oBrowse:SetCacheView(.F.)

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
	Local oStructSRA As Object
	Local oStructF5F As Object

	oModel := MPFormModel():New("RU07T04")
	oModel:SetDescription(STR0001) //Attendances

	//Header structure - SRA Employees
	oStructSRA := FWFormStruct(1, "SRA", {|cField| "|" + AllTrim(cField) + "|" $ "|RA_FILIAL|RA_CODUNIC|RA_MAT|RA_NOME|RA_ADMISSA|RA_TNOTRAB|RA_SEQTURN|"})
	oModel:AddFields("RU07T04_MSRA", /*cOwner*/, oStructSRA)
	oModel:GetModel("RU07T04_MSRA"):SetOnlyView(.T.)

	//Items structure - F5F Attendances
	oStructF5F := FWFormStruct(1, "F5F")

	oModel:AddGrid("RU07T04_MF5F", "RU07T04_MSRA", oStructF5F)
	oModel:GetModel("RU07T04_MF5F"):SetUniqueLine({"F5F_DTSTAR", "F5F_ATT"})

	oModel:SetRelation("RU07T04_MF5F", {{"F5F_FILIAL", 'xFilial("F5F")'}, {"F5F_MAT", "RA_MAT"}}, F5F->(IndexKey(1)))

	oEventRUS := RU07T04EventRUS():New()
	oModel:InstallEvent("RU07T04EventRUS", /*cOwner*/, oEventRUS)

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
	Local oView As Object
	Local oModel As Object
	Local oStructSRA As Object
	Local oStructF5F As Object

	oModel := FWLoadModel("RU07T04")

	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Header structure - SRA Employees
	oStructSRA := FWFormStruct(2, "SRA", {|cField| "|" + AllTrim(cField) + "|" $ "|RA_FILIAL|RA_CODUNIC|RA_MAT|RA_NOME|RA_ADMISSA|"})
	oStructSRA:SetNoFolder()
	oView:AddField("RU07T04_VSRA", oStructSRA, "RU07T04_MSRA")
	oView:SetViewProperty("RU07T04_VSRA", "OnlyView")
	
	//Items structure - F5F Attendances
	oStructF5F := FWFormStruct(2, "F5F")
	oStructF5F:RemoveField("F5F_MAT")
	oView:AddGrid("RU07T04_VF5F", oStructF5F, "RU07T04_MF5F")
	oView:AddIncrementField("RU07T04_VF5F", "F5F_SEQ")
	
	oView:CreateHorizontalBox("SRA_HEAD", 15)
	oView:CreateHorizontalBox("F5F_ITEM", 85)

	oView:SetOwnerView("RU07T04_VSRA", "SRA_HEAD")
	oView:SetOwnerView("RU07T04_VF5F", "F5F_ITEM")

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
	Local aRotina As Array

	aRotina := {}

	AAdd(aRotina, {STR0004, "VIEWDEF.RU07T04", 0, 2, 0, Nil}) //View
	AAdd(aRotina, {STR0005, "VIEWDEF.RU07T04", 0, 4, 0, Nil}) //Edit

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Filter range of codes of Types of Attendance (Standart Query SP9RUS)

@author D. Tereshenko
@since 11/14/2018
@version 1.0
@project MA3 - Russia
/*/

Function RU07T0401()
	Local nAttCode As Numeric
	Local lResult As Logical

	nAttCode := Val(F5F->F5F_ATT)
	lResult := (nAttCode >= 0 .And. nAttCode <= 99)

Return lResult  


//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T0401
Trigger from Attendance Start/End Date (F5F_DTSTAR/F5F_DTEND) - load Attendance Calendar Days (F5F_ATTDY)

@author D. Tereshenko
@since 11/14/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T0402()
	Local oModel As Object
	Local oModelF5F As Object
	Local dDateStart As Date
	Local dDateEnd As Date
	Local nAttDays As Numeric

	oModel := FWModelActive()
	oModelF5F := oModel:GetModel("RU07T04_MF5F")
	dDateStart := oModelF5F:GetValue("F5F_DTSTAR")
	dDateEnd := oModelF5F:GetValue("F5F_DTEND")

	nAttDays := 0

	If !Empty(dDateStart) .And. !Empty(dDateEnd)
		nAttDays := dDateEnd - dDateStart + 1
	EndIf

Return nAttDays


//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T0402
Trigger from Attendance Start/End Date (F5F_DTSTAR/F5F_DTEND) - load Attendance Hours (F5F_ATTHR)

@author D. Tereshenko
@since 11/14/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T0403()
	Local oModel As Object
	Local oModelF5F As Object
	Local dDateStart As Date
	Local dDateEnd As Date
	Local nAttDays As Numeric
	Local nAttHours As Numeric
	Local cRegNumber As Char
	Local cWorkShift As Char

	oModel := FWModelActive()
	oModelF5F := oModel:GetModel("RU07T04_MF5F")

	dDateStart := oModelF5F:GetValue("F5F_DTSTAR")
	dDateEnd := oModelF5F:GetValue("F5F_DTEND")
	cRegNumber := SRA->RA_MAT

	nAttDays := 0
	nAttHours := 0

	If !Empty(dDateStart) .And. !Empty(dDateEnd)
		nAttDays := dDateEnd - dDateStart + 1
		cWorkShift := Posicione("SRA", 1, xFilial("SRA") + cRegNumber, "RA_TNOTRAB")
		nAttHours := fRusWHrs(cWorkShift) * nAttDays
	EndIf

Return nAttHours


//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T0407
Check if transferred date is working day

@author D. Tereshenko
@since 11/14/2018
@version 1.0
@project MA3 - Russia
/*/
Function RU07T0407(cWorkShift As Char, cWkTimeSeq As Char, dDate As Date)
	Local cWeekDay As Char //PJ_DIA
	Local cIsWorkDay As Char
	Local lResult As Logical

	cWeekDay := AllTrim(Str(Dow(dDate)))

	cIsWorkDay := Posicione("SPJ", 1, xFilial("SPJ") + cWorkShift + cWkTimeSeq + cWeekDay, "PJ_TPDIA")

	lResult := (cIsWorkDay == "S")

Return lResult
