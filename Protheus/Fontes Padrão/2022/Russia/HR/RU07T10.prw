#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU07T10RUS.CH"


//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T10

Main function

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Function RU07T10()

Local oBrowse as Object

	oBrowse := BrowseDef()

	oBrowse:Activate()

Return Nil



//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Model definion

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Static Function ModelDef()

Local oModel		 	as Object
Local oStructSRA	 	as Object
Local oStructSR8 		as Object

// A model and structures initialization	

	oModel:= MpFormModel():New("RU07T10", /*Pre-Valid*/, {|oModel|RU07T1007(oModel)}, /*Commit*/, /*Cancel*/)

	oStructSRA := FWFormStruct(1, "SRA", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RA_CODUNIC|RA_MAT|RA_NOME|RA_ADMISSA|RA_TNOTRAB|RA_SEQTURN|"})   
	oStructSR8 := FWFormStruct(1, "SR8")

// Setting of properties

	oStructSR8:SetProperty('R8_MAT',		MODEL_FIELD_OBRIGAT, 	.F.)
	oStructSR8:SetProperty('R8_PER',		MODEL_FIELD_OBRIGAT, 	.F.)
	oStructSR8:SetProperty('R8_NUMPAGO',	MODEL_FIELD_OBRIGAT, 	.F.)
	oStructSR8:SetProperty('R8_PER',		MODEL_FIELD_INIT, 		.F.)
	oStructSR8:SetProperty('R8_NUMPAGO',	MODEL_FIELD_INIT, 		.F.)
	oStructSR8:SetProperty('R8_MEMO',		MODEL_FIELD_INIT, /*!isBlind()*/ .F.)
	
// Adding new fields and setting it's parameters

	oModel:AddFields("RU07T10_SRA", /*cOwner*/, oStructSRA)
	oModel:GetModel("RU07T10_SRA"):SetOnlyView( .T. ) // Sets that the submodel will not allow editing data.
	oModel:GetModel("RU07T10_SRA"):SetOnlyQuery( .T. ) // Sets that the submodel to be not written.

//Triggers for the calculation of absence days/hours for Russia

	if cPaisLoc == 'RUS' // TODO: To transfer to the metadata
		RU07T1008(oStructSR8, "R8_DURACAO", 0)
		oStructSR8:AddTrigger( "R8_DATAFIM", "R8_DURACAO", {|| .T. }, {|| RU07T1003(0) } )
		oStructSR8:AddTrigger( "R8_DATAFIM", "R8_QTDE",    {|| .T. }, {|| RU07T1003(1) } )
	Else
		RU07T1008(oStructSR8, "R8_DURACAO", 1)
	EndIf

	oModel:AddGrid("GPEA240_SR8", "RU07T10_SRA", oStructSR8,{|oModel, cAction|RU07T1006(oModel, cAction)})

	oModel:GetModel('GPEA240_SR8'):SetOptional(.T.) // Used if the submodel is optional.
	oModel:GetModel("GPEA240_SR8"):SetUniqueLine( { "R8_DATAINI" , "R8_TIPOAFA" } )

	oModel:SetRelation("GPEA240_SR8",{{"R8_FILIAL",'xFilial("SR8", SRA->RA_FILIAL)'},{"R8_MAT","RA_MAT"}},SR8->(IndexKey()))

Return oModel



//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

View definion

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Static Function ViewDef()

Local oModel 		as Object
Local oStructSRA 	as Object
Local oStructSR8 	as Object
Local oView 		as Object

// Model settings

	oModel	:= FWLoadModel("RU07T10")
	oView 	:= FWFormView():New()
	oView:SetModel(oModel)

// Creation of structure

	oStructSRA := FWFormStruct(2, "SRA", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RA_CODUNIC|RA_MAT|RA_NOME|RA_ADMISSA|"})
	oView:AddField("VIEWSRA", oStructSRA, "RU07T10_SRA")

	oStructSR8 := FWFormStruct(2, "SR8", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|R8_SEQ|R8_TIPOAFA|R8_DESCTP|R8_DATAINI|R8_DATAFIM|R8_DURACAO|R8_QTDE|"})
	oView:AddGrid("VIEWSR8", oStructSR8, "GPEA240_SR8")

	oStructSR8:RemoveField('R8_MAT')

// Setting of properties

	oView:SetViewProperty("RU07T10_SRA", "OnlyView") //Header View Only

	oView:createHorizontalBox("FORMFIELD", 15)
	oView:createHorizontalBox("GRID"  	 , 85)

	oView:SetOwnerView("VIEWSRA", "FORMFIELD")
	oView:SetOwnerView("VIEWSR8", "GRID")

	oView:AddIncrementField("VIEWSR8","R8_SEQ")

Return oView



//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Menu definion 

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Static Function MenuDef()

Local aRotina :=  {}

	aAdd( aRotina, { STR0010, 'VIEWDEF.RU07T10', 0, 2, 0, NIL } ) // View
	aAdd( aRotina, { STR0011, 'VIEWDEF.RU07T10', 0, 4, 0, NIL } ) // Edit
	aAdd( aRotina, { STR0012, 'VIEWDEF.RU07T10', 0, 5, 0, NIL } ) // Delete					

Return aRotina



//-------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Display initialization

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Static Function BrowseDef()

Local oBrowse as Object

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('SRA')
	oBrowse:SetDescription(STR0009)
	oBrowse:SetMenuDef('RU07T10')

Return oBrowse



//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T1001

Validation of the entry date of absence

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Function RU07T1001()

Local lRet 				as Logical
Local oModel 			as Object
Local oModelGrid 		as Object
Local cTHOTRAB 			as Character
Local cSEQTURN 			as Character
Local cStartDate	 	as Character
Local cEndDate 			as Character
Local cMode 			as Character
Local cFirstDay 		as Character
Local cLastDay 			as Character

	lRet := .T.

	oModel 		:= FWModelActive()
	oModelGrid 	:= oModel:GetModel('GPEA240_SR8')

	cTHOTRAB 	:= '001'//	SRA -> RA_TNOTRAB
	cSEQTURN 	:= '01'//	SRA -> RA_SEQTURN

	cStartDate 	:= oModelGrid:GetValue('R8_DATAINI')
	cEndDate 	:= oModelGrid:GetValue('R8_DATAFIM')

	If !Empty(cStartDate) .And. !Empty(cEndDate)

		
		cMode := '1'//	cMode := Posicione( "RCM", 1, xFilial( "RCM" ) + oModelGrid:GetValue('R8_TIPOAFA'), "RCM_DTCHK" )

		cFirstDay 	:= Posicione( "SPJ", 1, xFilial( "SPJ" ) + cTHOTRAB + cSEQTURN + Alltrim(Str(Dow(cStartDate))), "PJ_TPDIA" )
		cLastDay 	:= Posicione( "SPJ", 1, xFilial( "SPJ" ) + cTHOTRAB + cSEQTURN + AllTrim(Str(Dow(cEndDate))), "PJ_TPDIA" )

		If cMode <> '4'
			Do Case
				Case cMode == '1'
					If cFirstDay <> "S"
						Help(,,'HELP',, STR0007, 1, 0 )
						lRet := .F.
					EndIf
				Case cMode == '2'
					If cLastDay <> "S"
						Help(,,'HELP',, STR0007, 1, 0 )
						lRet := .F.
					EndIf

				Case cMode == '3'
					If cFirstDay <> "S" .OR. cLastDay <> "S"
						Help(,,'HELP',, STR0007, 1, 0 )
						lRet := .F.
					EndIF
				OtherWise
					lRet := .F.
			EndCase
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

Return  lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T1002

Validation of the absence duration in days allowed for input

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Function RU07T1002()

Local lRet 			as Logical
Local oModel 		as Object
Local oModelGrid 	as Object
Local nMinRCM 		as Numeric
Local nMaxRCM 		as Numeric
Local dStartDate
Local dEndDate

	lRet := .T.

	oModel 		:= FWMOdelActive()
	oModelGrid 	:= oModel:GetModel('GPEA240_SR8')

	dStartDate 	:= oModelGrid:GetValue('R8_DATAINI')
	dEndDate 	:= oModelGrid:GetValue('R8_DATAFIM')

	DbSelectArea("RCM")
	SR8->(dbSetOrder(1))

	If dbSeek(xFilial( "RCM" ) + RCM -> RCM_TIPO)
		nMinRCM := 1 //	RCM->RCM_MIN
		nMaxRCM := 3 //	RCM->RCM_DIASEM
		if !Empty(nMinRCM) .And. !Empty(nMaxRCM)
			if (dEndDate - dStartDate) + 1 > nMaxRCM .Or. (dEndDate - dStartDate) + 1 < nMinRCM
				Help(,,'HELP',, STR0008, 1, 0 )
				lRet := .F.
			EndIF
		EndIF
	Else
		 Help(,,'HELP',, STR0008, 1, 0 )
		lRet := .F.
	Endif

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T1003

Loading of fields Absence Calendar Days (R8_DURACAO) and Absence Hours (R8_QTDE)
	nType = 0 => Generate Absence Calendar Days in field R8_DURACAO
	nType = 1 => Generate Absence Hours in field R8_QTDE

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Function RU07T1003(nType as Numeric)

Local nRet 				as Numeric
Local oModel 			as Object
Local oModelGrid 		as Object
Local dStartDate 		as Date
Local dEndDate 			as Date
Local nWorkingHours 	as Numeric
Local cTHOTRAB 			as Character
Local nWorkingDays 		as Numeric
Local nPreHolidayDays 	as Numeric

	oModel 			:= FWModelActive()
	oModelGrid 		:= oModel:GetModel('GPEA240_SR8')
	dStartDate 		:= oModelGrid:GetValue('R8_DATAINI')
	dEndDate 		:= oModelGrid:GetValue('R8_DATAFIM')
	cTHOTRAB 		:= '001'//	SRA -> RA_TNOTRAB
	
	nRet := 0

	if !Empty(cTHOTRAB)
		nWorkingHours := Posicione('SR6', 1, xFilial('SR6') + cTHOTRAB, 'R6_HRDIA')
		nWorkingDays := GPEA40001(1, dStartDate, dEndDate)
		nWorkingHours := fRusWHrs(cTHOTRAB)
		nPreHolidayDays := 0 // Temporary value !

	if !Empty(dStartDate) .And. !Empty(dEndDate)
		Do Case
			Case nType == 0
				nRet := (dEndDate - dStartDate) + 1
			Case nType == 1
				nRet := nWorkingDays * nWorkingHours
		OtherWise
			nRet := 0
		EndCase
	EndIf

	EndIf

Return nRet



//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T1004

Validation of the information entried by the user (Absence Hours)

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Function RU07T1004()

Local lRet 			as Logical
Local oModel 		as Object
Local oModelGrid	as Object
Local nDays 		as Numeric
Local nHours 		as Numeric

	oModel 			:= FWModelActive()
	oModelGrid 		:= oModel:GetModel('GPEA240_SR8')
	nDays 			:= oModelGrid:GetValue('R8_DURACAO') //getvalue
	nHours 			:= oModelGrid:GetValue('R8_QTDE')

	lRet := .T.

	If !Empty(nHours)
		if nHours > (nDays * 24)
			lRet := .F.
		End if 
	Else
		lRet := .F.
	EndIF

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T1005

Function for Standart Query (RCMARU)
Show user codes which are between ranges 200 and 399 – with exeption of code 302.

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Function RU07T1005()

Local lRet as Logical

	lRet := VAL(RCM -> RCM_TIPO) >= 200 ;
		.And. VAL(RCM -> RCM_TIPO) <= 399 ;
		.And. VAL(RCM -> RCM_TIPO) != 302

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T1006

Pre-validation

User shall not be able to edit or delete information about absences generated through functionalities:
	Action of Business Trip – seek record on F4D table.
	Action of Vacation – seek record on RHI table.

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Function RU07T1006(oModelGrid as Object)

Local lRet as Logical
Local cStartDate := DtoS(oModelGrid:GetValue("R8_DATAINI"))

	lRet := .T.

	If oModelGrid:OFORMMODEL:NOPERATION == 3 .Or. oModelGrid:OFORMMODEL:NOPERATION == 4
		DbSelectArea("F4D")
		SR8->(dbSetOrder(1))
		If F4D->(DbSeek( xFilial("F4D",SRA->RA_FILIAL) + SRA->RA_CODUNIC + SRA->RA_MAT + cStartDate )) 
        	lRet := .F.
		EndIf
		If lRet
			DbSelectArea("RHI")
			SR8->(dbSetOrder(1))
				If RHI->(DbSeek( xFilial("RHI",SRA->RA_FILIAL) + SRA->RA_MAT + cStartDate )) 
        			lRet := .F.
				EndIf
			EndIF  
	EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T1007

Pos Validation include folowing validations:
	Absence End Date can not be lower than Absence Date,
	Absence Start Date can not be lower than employee’s admission date,
	It shall not be possible to include a new entry for a inactive employee (RA_MSQLBL = 2).

author:		Vadim Ivanov
since: 		25/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Function RU07T1007(oModel as Object)

Local lRet 				as Logical
Local oModelGrid 		as Object
Local nLen 				as Numeric
Local nActive 			as Character
Local dStartDate		as Date
Local dEndDate 			as Date
Local dAdmissionDate 	as Date

	lRet := .T.

	oModelGrid 			:= oModel:GetModel('GPEA240_SR8')
	nLen 				:= oModelGrid:GetLine() // Returns the current line number

// Getting the required parameters

	dStartDate 			:= oModelGrid:GetValue('R8_DATAINI')
	dEndDate 			:= oModelGrid:GetValue('R8_DATAFIM')
	dAdmissionDate 		:= SRA -> RA_ADMISSA
	nActive 			:= SRA -> RA_MSBLQL

//Checks

	If !Empty(dStartDate) .And. !Empty(dEndDate) .And. !Empty(dAdmissionDate)
		if nLen >= 1
			If dEndDate < dStartDate
				lRet := .F.
			EndIf
			If dStartDate < dAdmissionDate
				lRet := .F.
			EndIF
			If nActive != '2'
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} RU07T1008

Disabling a trigger for a field
	oStruct - Strucrure
	cField - Name of field
	nMode -
			0 - Disable all triggers for cField
			1 - Activate all triggers for cField

author:		Vadim Ivanov
since: 		29/12/2018
version: 	1.0
project: 	MA3 - Russia
-------------------------------------------------------------------/*/

Function RU07T1008(oStruct as Object,cField as Character, nMode as Numeric)

Local aTriggers as Array
Local nTrigger as Numeric

		aTriggers := oStruct:GetTriggers()
		For nTrigger := 1 to Len(aTriggers)
			If aTriggers[nTrigger][1] == cField
				if nMode == 0
					aTriggers[nTrigger][3] := {|| .F.}
				Else
					aTriggers[nTrigger][3] := {|| .T.}
				EndIf
			EndIf
		Next
Return