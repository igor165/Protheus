#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE STR0001 "Absenses"
#DEFINE STR0002 "View"
//#DEFINE STR0003 ""
#DEFINE STR0004 "Update"
#DEFINE STR0005 "Delete"



Function R07NEWTEST()

//It runs the routine

Local oBrowse as Object

	oBrowse := BrowseDef()

	oBrowse:Activate()

Return Nil



Static Function ModelDef()

// Data model initilization

Local oStructSRA	 	as Object
Local oModel		 	as Object
Local oStructSR8 		as Object
Local oModelGrid 		as Object


// A model and structures initialization

	oModel:= MpFormModel():New("RU07T10RUSM", /* Pre-valid */,{|oModel| /*RU07T10002(oModel),*/ bLinePost()  },/* Commit */,/* Cancel */ )

	oStructSRA := FWFormStruct(1, "SRA", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RA_CODUNIC|RA_MAT|RA_NOME|RA_ADMISSA|RA_TNOTRAB|RA_SEQTURN|"})   
	oStructSR8 := FWFormStruct(1, "SR8", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|R8_SEQ|R8_TIPOAFA|R8_DESCTP|R8_DATAINI|R8_DATAFIM|R8_DURACAO|R8_QTDE|"})

// Adding new fields and setting it's parameters.

	oModel:AddFields("SRAMASTER", /*cOwner*/, oStructSRA)

	oModel:GetModel("SRAMASTER"):SetOnlyView( .T. ) // Sets that the submodel will not allow editing data.
	oModel:GetModel("SRAMASTER"):SetOnlyQuery( .T. ) // Sets that the submodel to be not written.

	oModel:AddGrid("SR8DETAILS", "SRAMASTER", oStructSR8	)

	oModel:GetModel('SR8DETAILS'):SetOptional(.T.) // Used if the submodel is optional.
	oModel:GetModel('SR8DETAILS'):SetUseOldGrid(.T.) // Used for compatibility with the old Protheus Browse.

/* Setting properties

	oStructSR8:SetProperty("R8_SEQ",MODEL_FIELD_INIT,FwBuildFeature( STRUCT_FEATURE_INIPAD, 'Gp240GetSeq()' ) )
	oStructSR8:SetProperty( "R8_DATAINI", MODEL_FIELD_WHEN, { |oGrid| !( Empty(oGrid:GetValue("R8_TIPOAFA")) ) } )
	oStructSR8:SetProperty( "R8_DURACAO", MODEL_FIELD_WHEN, { |oGrid| !( Empty(oGrid:GetValue("R8_TIPOAFA")) ) } )
	oStructSR8:SetProperty( "R8_DATAFIM", MODEL_FIELD_WHEN, { |oGrid| !( Empty(oGrid:GetValue("R8_TIPOAFA")) ) } )

*/

	//FWMemoVirtual( oStructSR8,{ { 'R8_CODMEMO' , 'R8_MEMO' } } )

	//oModel:GetModel("SR8DETAILS"):SetUniqueLine( { "R8_DATAINI" , "R8_TIPOAFA" } )

	oModel:SetRelation("SR8DETAILS",{{"R8_FILIAL",'xFilial("SR8", SRA->RA_FILIAL)'},{"R8_MAT","RA_MAT"}},SR8->(IndexKey()))

Return oModel



Static Function ViewDef()

// View model initialization

Local oModel 		as Object
Local oStructSRA 	as Object
Local oStructSR8 	as Object
Local oView 		as Object

	oModel	:= FWLoadModel("RU07T10RUS")

	oView := FWFormView():New()

	oView:SetModel(oModel)

	oStructSRA := FWFormStruct(2, "SRA", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|RA_CODUNIC|RA_MAT|RA_NOME|RA_ADMISSA|"})

	oView:AddField("VIEWSRA", oStructSRA, "SRAMASTER")

	oStructSR8 := FWFormStruct(2, "SR8", {|cCampo| "|"+ AllTrim(cCampo) + "|" $ "|R8_SEQ|R8_TIPOAFA|R8_DESCTP|R8_DATAINI|R8_DATAFIM|R8_DURACAO|R8_QTDE|"})

	oView:AddGrid("VIEWSR8", oStructSR8, "SR8DETAILS")

	oView:SetViewProperty("SRAMASTER", "OnlyView") //Header View Only

	oView:createHorizontalBox("FORMFIELD", 15)
	oView:createHorizontalBox("GRID"  	 , 85)


	oView:SetOwnerView("VIEWSRA", "FORMFIELD")
	oView:SetOwnerView("VIEWSR8", "GRID")

	oView:AddIncrementField("VIEWSR8","R8_SEQ")

Return oView



Static Function MenuDef()

// It creates a menu buttons

Local aRotina :=  {}

	aAdd( aRotina, { STR0002, 'VIEWDEF.RU07T10RUS', 0, 2, 0, NIL } ) // View
	aAdd( aRotina, { STR0004, 'VIEWDEF.RU07T10RUS', 0, 4, 0, NIL } ) // Edit
	aAdd( aRotina, { STR0005, 'VIEWDEF.RU07T10RUS', 0, 5, 0, NIL } ) // Delete					

Return aRotina



Static Function BrowseDef()

// Display initialization

Local oBrowse as Object

	oBrowse := FWMBrowse():New()

	oBrowse:SetAlias('SRA')
	oBrowse:SetDescription(STR0001)
	//GpLegend(@oBrowse,.T.)
	oBrowse:SetMenuDef('RU07T10RUS')

Return oBrowse


Function fRcmAFil()

// Standart Query RCMARU

Local lRet as Logical

Local cA := RCM -> RCM_CODE
LOcal nA := VAL(cA)

lRet := VAL(RCM -> RCM_CODE) >= 200 ;
	.And. VAL(RCM -> RCM_CODE) <= 399 ;
	.And. RCM -> RCM_CODE != '302'

Return lRet



Function RU07T10001()

// It validates entry date of absence.

Local lRet as Logical
Local oModel as Object
Local oModelGrid as Object
Local cTHOTRAB as Character
Local cSEQTURN as Character
Local StartDate as Character
Local cEndDate as Character
Local cMode as Character
Local lFirstDay as Logical
Local lLastDay as Logical

lRet := .T.

oModel := FWModelActive()
oModelGrid := oModel:GetModel('SR8DETAILS')
cTHOTRAB := SRA -> RA_TNOTRAB
cSEQTURN := SRA -> RA_SEQTURN

cStartDate 	:= oModelGrid:GetValue('R8_DATAINI')
cEndDate 	:= oModelGrid:GetValue('R8_DATAFIM')

If !Empty(AllTrim(cStartDate)) .And. !Empty(AllTrim(cEndDate))

	cMode := Posicione( "RCM", 1, xFilial( "RCM" ) + oModelGrid:GetValue('R8_TIPOAFA'), "RCM_DTCHK" )

	Do Case
		Case cMode := '1'
			lFirstDay := iif(Posicione( "SPJ", 1, xFilial( "SPJ" ) + cTHOTRAB + cSEQTURN + Dow(CTOD(StartDate)), "PJ_TPDIA" ) == "S", .T., .F.)
			lRet := lFirstDay
		Case cMode := '2'
			lLastday := iif(Posicione( "SPJ", 1, xFilial( "SPJ" ) + cTHOTRAB + cSEQTURN + Dow(CTOD(EndDate)), "PJ_TPDIA" ) == "S", .T., .F.)
			lRet = lLastDay
		Case cMode := '3'
			lFirstDay := iif(Posicione( "SPJ", 1, xFilial( "SPJ" ) + cTHOTRAB + cSEQTURN + Dow(CTOD(StartDate)), "PJ_TPDIA" ) == "S", .T., .F.)
			lLastday  := iif(Posicione( "SPJ", 1, xFilial( "SPJ" ) + cTHOTRAB + cSEQTURN + Dow(CTOD(EndDate)), "PJ_TPDIA" ) == "S", .T., .F.)
			lRet := (lFirstDay == lLastday) == .T.
		Case cMode := '4'
			lRet := .T.
	OtherWise
		lRet := .F.
	EndCase

EndIf

Return  lRet


Function RU07T10002()

// It validates duration of absence in days allowed for input.

Local lRet as Logical
Local oModel as Object
Local oModelGrid as Object

Local nDuration as Numeric

Local nMinRCM as Numeric
Local nMaxRCM as Numeric

	lRet := .T.

	oModel := FWMOdelActive()
	oModelGrid := oModel:GetModel('SR8DETAILS')

	nDuration := oModelGrid:GetValue("R8_DURACAO")

	DbSelectArea("RCM")
	SR8->(dbSetOrder(1))

	If dbSeek(xFilial( "RCM" ) + oModelGrid:GetValue("RCM_TIPO"))
		nMinRCM := RCM->RCM_MIN
		nMaxRCM := RC8->RCM_DIASET
		if nDuration > nMaxRCM .Or. nDuration < nMinRCM
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet



Function RU07T10003(nType as Numeric)

// It loads fields Absence Calendar Days (R8_DURACAO) and Absence Hours (R8_QTDE).
// nType = 1 => Generate Absence Calendar Days in field R8_DURACAO
// nType = 2 => Generate Absence Hours in field R8_QTDE

Local nRet 				as Numeric
Local oModel 			as Object
Local oModelGrid 		as Object
Local dStartDate 		as Date
Local dEndDate 			as Date
Local nAbsDays 			as Numeric
Local nAbsHours 		as Numeric
Local nWorkingHours 	as Numeric
Local cTHOTRAB 			as Character
Local nWorkingDays 		as Numeric
Local nWorkingHours 	as Numeric
Local nPreHolidayDays 	as Numeric

	oModel 			:= FWModelActive()
	oModelGrid 		:= CTOD(oModel:GetModel('SR8DETAILS'))
	dStartDate 		:= CTOD(oModelGrid:GetValue('R8_DATAINI'))
	dEndDate 		:= CTOD(oModelGrid:GetValue('R8_DATAFIM'))
	cTHOTRAB 		:= SRA -> RA_TNOTRAB
	
	nAbsDays := 0

	//nWorkingHours := Posicione('SRA', 1, xFilial('SRA') + cTHOTRAB, 'R6_HRDIA')
	nWorkingDays := GPEA40001(1, dStartDate, dEndDate)
	nWorkingHours := fRusWHrs(cTHOTRAB)
	nPreHolidayDays := 0 // Temporary value !


	if !Empty(AllTrim(dStartDate)) .And. !Empty(AllTrim(dEndDate))
		Do Case
			Case nType == 1
				nAbsDays := (dEndDate - dStartDate) + 1
				nRet := nAbsDays
			Case nType == 2
				nAbsHours := (nWorkingDays * nWorkingHours) + (nPreHolidayDays * nWorkingHours - 1)
				nRet := nAbsHours
		OtherWise
			nRet = " "
		EndCase
	EndIf
	
Return nRet



Function RU07T10004()

// It validates information entried by the user (Absence Hours).

Local oModel as Object
Local oModelGrid as Object
Local nAbsHours as Numeric

	oModel := FWModelActive()
	oModelGrid := oModel:GetModel('SR8DETAILS')

Return




Function bLinePost()

// Pos Validation

Local lRet 				as Logical
Local oModel 			as Object
Local oModelGrid 		as Object
Local nLen 				as Numeric
Local nActive 			as Character
Local dStartDate		as Date
Local dEndDate 			as Date
Local dAdmissionDate 	as Date

	lRet := .T.

	oModel := FWModelActive()
	oModelGrid := oModel:GetModel('SR8DETAILS')
	nLen := oModelGrid:GetLine() // Returns the current line number

// Getting the required parameters

	dStartDate 			:= IIF(AllTrim(SR8 -> R8_DATAINI) == "//", "", CTOD(SR8 -> R8_DATAINI))
	dEndDate 			:= IIF(AllTrim(SR8 -> R8_DATAFIM) == "//", "", CTOD(SR8 -> R8_DATAFIM))
	dAdmissionDate 		:= IIF(AllTrim(SRA -> RA_ADMISSA) == "//", "", CTOD(SRA -> RA_ADMISSA))
	nActive 			:= SRA -> RA_MSQLBL

//Checks

	If !Empty(dStartDate) .And. !Empty(dEndDate) .And. !Empty(dAdmissionDate)
		if nLen > 1
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

/*{Protheus.doc} GPEA40001
Function returns number of Working or Non-Working days in period

	IT'S NOT A MISTAKE!
	This function was specially transferred from the source "GPEA400.PRW" 
	here to preserve the functionality of that part of the localization where the function is used, 
	since all changes in GPEA400.PRW were rolled back to the standard.

@type  		Function
@author		Ekaterina.Moskovkira
@since		23.04.2018
@version	001
@param 		nCalcType	Numeric	Indicates if we need to calc Working days (=1) or Non-Working days (=0)
			dBegDate 	Date	Beginning of period
			dEndDate 	Date	End of period
@return 	nDaysCalc	Numeric Count of days
*/
Function RGPEA40001 (nCalcType, dBegDate, dEndDate)
Local	aArea		:= getArea()
Local	cMyAlias	:= GetNextAlias()
Local	cQuery		:= ""

Local	nDaysCalc	as Numeric
// Workdays will be calculated by default
Default nCalcType := 1

	cQuery := "SELECT COUNT(1) AS DAYS_COUNT"
	cQuery += " FROM"
	cQuery += " (SELECT	CLNDR.GENERATE_SERIES, "
	cQuery += " 	CASE	WHEN	( EXTRACT( DOW FROM CLNDR.GENERATE_SERIES ) NOT IN (0, 6) "
	cQuery += " 				AND P3.R_E_C_N_O_ IS NULL ) "
	cQuery += " 			OR ( P3.R_E_C_N_O_ IS NOT NULL AND P3.P3_TPDAY = '2' ) "
	cQuery += " 		THEN 	1 "
	cQuery += " 		ELSE 	0 "
	cQuery += " 	END AS WDTYPE "
	cQuery += " FROM "
	cQuery += " (SELECT * FROM GENERATE_SERIES('" + DTOS(dBegDate) + "', '" + DTOS(dEndDate) + "', '1 DAY'::INTERVAL) )	CLNDR "
	cQuery += " LEFT JOIN "  + RetSqlName("SP3")  + " P3 "
	cQuery += " 	ON CLNDR.GENERATE_SERIES = P3.P3_DATA::date AND P3.D_E_L_E_T_ = '' "
	cQuery += " ) C_DAYS"
	cQuery += " WHERE C_DAYS.WDTYPE = " + STR( nCalcType )
	//cQuery := ChangeQuery(cQuery)

	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery), cMyAlias, .T., .T. )
	( cMyAlias ) -> ( DBGoTop() )
    While  ( cMyAlias ) -> ( !EOF() ) 
        nDaysCalc := ( cMyAlias ) -> DAYS_COUNT
        ( cMyAlias ) -> ( DbSkip() )
    EndDo 
            
    ( cMyAlias ) -> ( dbCloseArea() )

	RestArea( aArea )
Return nDaysCalc
