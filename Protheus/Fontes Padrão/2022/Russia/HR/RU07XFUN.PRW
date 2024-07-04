#INCLUDE "PROTHEUS.CH"
#INCLUDE "RU07XFUN.CH"

#DEFINE RUSS20604_LENGTH 9
#DEFINE RUSS20605_LENGTH 9
#DEFINE RUSS20606_LENGTH 6
#DEFINE RUSS20607_LENGTH 2
#DEFINE RUSS20608_LENGTH 11
#DEFINE RUSS206_KEY_POSITION 145
#DEFINE RUSS206_PERCENT_POSITION 11
#DEFINE RUSS206_PERCENT_LENGTH 6

#DEFINE WORK_EXPERIENCE_REFTYPES {STREXP01, STREXP02, STREXP03, STREXP04, STREXP05, STREXP06, STREXP07, STREXP08, STREXP09}

/*
{Protheus.doc} RU07CHKRS(cMat As Char)
    Checks if the employee with transfered reg. number is a tax resident of the Russian Federation 
        based on their abroad absence (table SR8).

    @type Function
    @params cMat,    Char,    Employee's registration number
    @author dtereshenko
    @since 02/19/2020
    @version 12.1.23
    @return lIsResident,    Logical,    Indicator of whether the employee is a tax resident
*/
Function RU07CHKRS(cMat As Char)
    Local lIsResident As Logical
    Local oStatement As Object
    Local cQuery As Char
    Local cCurrentYear As Char
    Local cYearStart As Char
    Local cYearEnd As Char
    Local dDateStart As Date
    Local dDateEnd As Date
    Local nDaysAbroad As Numeric

    lIsResident := .T.
    nDaysAbroad := 0
    cCurrentYear := SubStr(DToS(dDataBase), 1, 4)
    cQuery := "SELECT R8_DATAINI, R8_DATAFIM FROM " + RetSQLName("SR8") + " WHERE R8_FILIAL = ? AND R8_MAT = ? AND R8_ABROAD = ? AND D_E_L_E_T_ = ' '"

    oStatement := FWPreparedStatement():New()

    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, xFilial("SR8"))
    oStatement:SetString(2, cMat)
    oStatement:SetString(3, "T")

    cAbroadAbsences := MPSysOpenQuery(oStatement:GetFixQuery(), GetNextAlias())

    DBSelectArea(cAbroadAbsences)
    (cAbroadAbsences)->(DbGoTop())
    While !EoF()
        cYearStart := SubStr((cAbroadAbsences)->R8_DATAINI, 1, 4)
        cYearEnd := SubStr((cAbroadAbsences)->R8_DATAFIM, 1, 4)

        If cYearStart == cCurrentYear .Or. cYearEnd == cCurrentYear
            dDateStart := IIf(cYearStart == cCurrentYear, SToD((cAbroadAbsences)->R8_DATAINI), SToD(cCurrentYear + "0101"))
            dDateEnd := IIf(cYearEnd == cCurrentYear, SToD((cAbroadAbsences)->R8_DATAFIM), SToD(cCurrentYear + "1231"))
            nDaysAbroad += dDateEnd - dDateStart
        EndIf

        DBSkip()
    EndDo
    DBCloseArea()

    lIsResident := ( nDaysAbroad <= 183 )

Return lIsResident

/*
{Protheus.doc} fRUGetNP(cS207ID As Char)
    Function for getting the percentage value from table S207 (Northern Premium)

    @type Function
    @params cS205ID,    Char,    S207 entry code
    @author dtereshenko
    @since 02/28/2020
    @version 12.1.23
    @return nNP,    Numeric,    Value of NP percentage
*/
Function fRUGetNP(cS207ID As Char)
    Local aS207Lines As Array
    Local nNP As Numeric
    Local nI As Numeric

    aS207Lines := {}

    fCarrTab(@aS207Lines, "S207")

    For nI := 1 To Len(aS207Lines)
        If aS207Lines[nI][1] == "S207"
            If aS207Lines[nI][5] == cS207ID
                nNP := aS207Lines[nI][6]
            EndIf
        EndIf
    Next nI

Return nNP


/*
{Protheus.doc} RU07DATAUPLOAD()
    Function for uploading master-data required for control example of salary calculation

    @type Function
    @params
    @author dtereshenko
    @since 03/03/2020
    @version 12.1.25
    @return
*/
Function RU07DATAUPLOAD()
    Local aTablesForUpload As Array
    Local nI As Numeric
    Local aCodFol As Array

    aTablesForUpload := {"RCB", "RCC", "RCA", "SRV", "RCN", "RCM", "RC2", "RC3", "SRY", "SRM"}

    For nI := 1 To Len(aTablesForUpload)
        TCDelFile(RetSqlName(aTablesForUpload[nI]))
    Next nI

    GpIniTab()   // RCB - Parameters Configuration (gpea310)
    GpTABCRG()
    GpIniCRG()   // RCC - Parameters (gpea320)

    fCarPD()     // SRV - Budgets (gpea040)
    Fp_CodFol(aCodFol, xFilial("RCN"), .F.) // RCN - Calculation Identifiers (gpea040)

    gpea430()    // RCM - Absence Types (static fCargaRCM)
    fCarMnemo()  // RCA - Mnemonics (gpea300)
    gpea160m()   // SRY, SRM, RC2, RC3 - Calculation Procedures, Calculation Script Items, Formulas Headers, Formulas

    // If FindFunction("RU07XFUNRU")
    //     RU07XFUNRU() // Removed due to direct access in ditionary 
    // EndIf

Return

/*
{Protheus.doc} fRUGetRF(cDept As Char, cCC As Char, cRegion As Char, cState As Char, cCityCode As Char)
    Function for getting the percentage value from table S206 (Regional Factor)
        according to parts of its essential key

    @type Function
    @params cDept,        Char,       Department (RA_DEPTO)
            cCC,          Char,       Cost Center (RA_CC)
            cRegion,      Char,       Department Region (QB_REGIAO)
            cState,       Char,       State (RA_ESTADO)
            cCityCode,    Char,       City Code (RA_CODMUN)
    @return nRegFactor,   Numeric,    Value of RF percentage
    @author dtereshenko
    @since 03/17/2020
    @version 12.1.23
*/
Function fRUGetRF(cDept As Char, cCC As Char, cRegion As Char, cState As Char, cCityCode As Char)
    Local aRegionalFactors As Array
    Local nI As Numeric
    Local nRegFactorValue As Numeric

    Default cRegion := ""

    nRegFactorValue := 0
    aRegionalFactors := {}

    fCarrTab(@aRegionalFactors, "S206")

    For nI := 1 To Len(aRegionalFactors) // Change to hashmap if there will be more than 10 entries
        If aRegionalFactors[nI][1] == "S206"
            If aRegionalFactors[nI][8]  == PadR(cDept, RUSS20604_LENGTH, " ") .And. ;
            aRegionalFactors[nI][9]  == PadR(cCC, RUSS20605_LENGTH, " ") .And. ;
            aRegionalFactors[nI][10] == PadR(cRegion, RUSS20606_LENGTH, " ") .And. ;
            aRegionalFactors[nI][11] == PadR(cState, RUSS20607_LENGTH, " ") .And. ;
            aRegionalFactors[nI][12] == PadR(cCityCode, RUSS20608_LENGTH, " ")

                nRegFactorValue := aRegionalFactors[nI][6]
                Exit
            EndIf
        EndIf
    Next nI

Return nRegFactorValue

/*
{Protheus.doc} fRUGetAV()
    Function for retrieving array of SRV codes required for average salary calculation

    @type Function
    @params
    @return aSRVAverages,    Array,    Array for SRV codes
    @author dtereshenko
    @since 06/01/2020
    @version 12.1.23
*/
Function fRUGetAV()
    Local cSRVFilial := FWXFilial("SRV")
    Local cRevenueTipoCod := "1"
    Local aSRVAverages := {}

    DbSelectArea("SRV")
    DbSetOrder(4) // RV_FILIAL + RV_TIPOCOD + RV_COD

    If DbSeek(cSRVFilial + cRevenueTipoCod, .T.)
        While !EoF() .And. SRV->RV_FILIAL == cSRVFilial
            If SRV->RV_MEDFER == "AV"
                AAdd(aSRVAverages, SRV->RV_COD)
            EndIf
            dbSkip()
        EndDo
    EndIf

    DbCloseArea()

Return aSRVAverages

/*
{Protheus.doc} fRUMIDMED(aSRVAverages As Array)
    Function for retrieving sum of AV-type payments

    @type Function
    @params aSRVAverages,       Array,      Array of SRV AV-type codes
    @return nSRVAveragesSum,    Numeric,    Sum of values (RC_VALOR) with AV-type codes
    @author dtereshenko
    @since 06/01/2020
    @version 12.1.23
*/
Function fRUMIDMED(aSRVAverages As Array)
    Local nI As Numeric
    Local cSRVCodes := ""
    Local nSRVAveragesSum := 0

    Default aSRVAverages := {}

    For nI := 1 To Len(aSRVAverages)
        cSRVCodes += aSRVAverages[nI] + "|"
    Next nI

    nSRVAveragesSum := FBuscaPD(cSRVCodes)

Return nSRVAveragesSum

/*
{Protheus.doc} fRUAverCalc(cMat As Char, dBaseDate As Date, oMonths As Object)
    Returns average employee earnings per day for the previous period (12 months)

    @type Function
    @params cMat,          Char,       Employee's Reg. Number (RA_MAT)
            dBaseDate      Date,       Date for calculating average earnings for the previous period (12 months)
            oMonths        Object      Output RUMap with calendar days without absences & receiving AV-payments per period
    @return nAverValue,    Numeric,    Average employee earnings per day for the previous period (12 months)
    @author dtereshenko
    @since 06/04/2020
    @version 12.1.23
*/
Function fRUAverCalc(cMat As Char, dBaseDate As Date, oMonths As Object)
    Local aMonth As Array
    Local cMonth As Char
    Local nI As Numeric
    Local nAverValue As Numeric
    Local nAverMonthDays As Numeric
    Local nAverDays := 0
    Local nAverMoney := 0
    Local aMonths := {}

    Local cRUSAvDaysCodFol := aCodFol[1748, 1]
    Local cRUSAvMoneyCodFol  := aCodFol[1749, 1]

    Local nBaseYear := Year(dBaseDate)
    Local nBaseMonth := Month(dBaseDate)

    nAverMonthDays := fGetAvMonthDays()

    // Fill aray by previous periods (months)
    For nI := 1 To 12
        nBaseMonth -= 1

        If nBaseMonth == 0
            nBaseMonth := 12
            nBaseYear -= 1
        EndIf

        cMonth := Str(nBaseYear, 4) + StrZero(nBaseMonth, 2)

        AAdd(aMonths, cMonth)
        oMonths:Set(cMonth, {0, 0})
    Next nI

    // Check payments from opened period
    GetSRCAvRecords(cMat, aMonths, cRUSAvDaysCodFol, cRUSAvMoneyCodFol, @oMonths)

    // Check payments from closed periods
    GetSRDAvRecords(cMat, aMonths, cRUSAvDaysCodFol, cRUSAvMoneyCodFol, @oMonths)

    // Calculate average values
    oMonths:List(aMonths)
    For nI := 1 To Len(aMonths)
        cMonth := aMonths[nI][1]
        aMonth := aMonths[nI][2]

        If aMonth[1] == 0 .And. aMonth[2] == 0
            oMonths:Del(cMonth)
        Else
            nAverDays += nAverMonthDays * aMonth[1] / fGetMonthDays(cMonth)
            nAverMoney += aMonth[2]
        EndIf
    Next nI

    nAverValue := nAverMoney / nAverDays

Return nAverValue

/*
{Protheus.doc} fGetMonthDays(cMonth As Char)
    Returns number of days per period (month)

    @type Function
    @params cMonth,    Char,       Required period (YYYYMM)
    @return nDays,     Numeric,    Number of days
    @author dtereshenko
    @since 06/04/2020
    @version 12.1.23
*/
Static Function fGetMonthDays(cMonth As Char)
    Local nDays As Numeric

    DbSelectArea("RCH")
    DbSetOrder(9) // RCH_FILIAL + RCH_PER + RCH_NUMPAG + RCH_PROCES + RCH_ROTEIR + RCH_PERSEL

    If DbSeek(FWXFilial("RCH") + cMonth)
        nDays := Day(RCH->RCH_DTFIM) - Day(RCH->RCH_DTINI) + 1
    EndIf

    DbCloseArea()

Return nDays

/*
{Protheus.doc} fGetAvMonthDays()
    Returns average monthly number of calendar days per year (S208 table)

    @type Function
    @params
    @return nDays,    Numeric,    Average number of days (by government decree)
    @author dtereshenko
    @since 06/04/2020
    @version 12.1.23
*/
Static Function fGetAvMonthDays()
    Local nDays As Numeric

    DbSelectArea("RCC")

    If DbSeek(FWXFilial("RCC") + "S208")
        nDays := Val(SubStr(RCC->RCC_CONTEU, 1, 5))
    EndIf

    DbCloseArea()

Return nDays

/*
{Protheus.doc} RU07XFUN01_WorkShiftEmptyHours(cTurno As Char)
    Checks whether transfered Work Shift doesn't contain number of working hours

    @type Function
    @params cTurno,         Char,       Work Shift ID (R6_TURNO)
    @return lHoursEmpty,    Logical,    Check result
    @author dtereshenko
    @since 2020/07/02
    @version 12.1.23
*/
Function RU07XFUN01_WorkShiftEmptyHours(cTurno As Char)
    Local lHoursEmpty As Logical

    lHoursEmpty := Empty(Posicione("SR6", 1, FWXFilial("SR6") + cTurno, "R6_HRDIA"))

Return lHoursEmpty

/*/
{Protheus.doc} fRUGetRccConteo(cCodigo As Char, cKey As Char)
    Returns RCC_CONTEU by given RCC_CODIGO and first RCC_CONTEU part

    @type Method
    @params cCodigo,    Char,    RCC_CODIGO
            cKey,       Char,    First RCC_CONTEU part
    @author dtereshenko
    @since 10/02/2019
    @version 12.1.23
    @return cRccConteo,    Char,    RCC_CONTEU
/*/
Function fRUGetRccConteo(cCodigo As Char, cKey As Char)
    Local cRccConteo := ""
    Local aSavedArea := GetArea()

    dbSelectArea("RCC")
    dbSeek(xFilial("RCC") + cCodigo)

    While !EoF() .And. RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC") + cCodigo
        If ( RCC->RCC_FILIAL+RCC_CODIGO == xFilial("RCC") + cCodigo ) .And. ;
           ( Substr(RCC->RCC_CONTEU, 1, Len(cKey)) == cKey )

            cRccConteo := RCC->RCC_CONTEU
            Exit
        EndIf
        dBSkip()
    EndDo
    dbCloseArea()
    RestArea(aSavedArea)

Return cRccConteo

/*/
{Protheus.doc} fRUGetCIC(cMat As Char)
    Returns SNILS (RA_CIC) of given employee by reg. number (RA_MAT)

    @type Method
    @params cMat,   Char,   Employee's reg. number (RA_MAT)
    @return cCIC,   Char,   Employee's SNILS (RA_CIC)
    @author dtereshenko
    @since 2020/07/21
    @version 12.1.23
/*/
Function fRUGetCIC(cMat As Char)
    Local cCIC := ""
    Local aSavedArea := GetArea()

    dbSelectArea("SRA")
    dbSetOrder(1) // RA_FILIAL + RA_MAT + RA_NOME
    If SRA->(dbSeek(xFilial("SRA") + cMat))
        cCIC := SRA->RA_CIC
    EndIf
    dbCloseArea()
    RestArea(aSavedArea)

Return cCIC

/*{Protheus.doc} fRuDisDay
    Calculates the number of days without Sick Leave and
    pregnancy and childbirth for employee personnel number in the month dBaseDate.

    @type  Function
    @author vselyakov
    @since 2020/07/23
    @version 12.1.23
    @param cMat, Character, Employee personnel number
           dBaseDate, Date, Date for calculating day without Sick Leave and pregnancy and childbirth count in month.
    @return return, return_type, return_description
    @example fRuDisDay('000019', STOD('20200305'))
*/
Function fRuDisDay(cMat As Char, dBaseDate As Date)
    Local nDays      As Numeric
    Local cMonth     As Character
    Local aCurArea   As Array
    Local aAbsCodes  As Array
    Local oStatement As Object
    Local cQuery     As Character
    Local cAlias     As Character
    Local cMonStart  As Character
    Local cMonFin    As Character

    Default dBaseDate := dDataBase

    aCurArea := GetArea()
    nDays := 0
    cMonth := Substr(DTOS(dBaseDate), 1, 6)

    // Fill array of absences types.
    aAbsCodes := { '003', '004', '006', '007' , '008', '009', '010', '011', '017' }

    // SQL query for the list of absences for the employee, except for the codes of absences in the aAbsCodes array.
    oStatement := FWPreparedStatement():New()
    cQuery := " SELECT R8_DATAINI AS DINIT, R8_DATAFIM AS DFIN FROM " + RetSQLName("SR8") + " WHERE "
    cQuery += " R8_MAT=? "
    cQuery += " AND R8_TIPOAFA NOT IN (?) "
    cQuery += " AND D_E_L_E_T_=' ' "
    
    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, cMat)
    oStatement:SetIn(2, aAbsCodes)

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery(), "cAlias")

    DBSelectArea(cAlias)
    DBGoTop()

   WHILE !EOF()
      cMonStart := Substr((cAlias)->DINIT, 1, 6)
      cMonFin   := Substr((cAlias)->DFIN, 1, 6)
      
      If cMonth == cMonStart .AND. cMonth == cMonFin
        nDays +=  (STOD((cAlias)->DFIN) - STOD((cAlias)->DINIT)) + 1
      EndIf

      DBSkip()
   ENDDO

    // Destroy FWPreparedStatement object.
    oStatement:Destroy()
    FwFreeObj(oStatement)

    RestArea(aCurArea)
Return nDays

/*
{Protheus.doc} fRUDisShCal(cMat As Char, dBaseDate As Date, oMonths As Object)
    Returns average earnings for paying a disability sheet according to legal rules.

    @type Function
    @params cMat,           Char,       Employee's Reg. Number (RA_MAT)
            dBaseDate       Date,       Date for calculating average earnings for the previous period (last 2 years)
            oMonths         Object      Output RUMap with calendar days without absences & receiving INSS-payments per period
    @return nAverDSValue,   Numeric,    Average employee earnings per day for the previous period (12 months)
    @author dtereshenko
    @since 2020/08/12
    @version 12.1.23
*/
Function fRUDisShCal(cMat As Char, dBaseDate As Date, oMonths As Object)
    Local cPeriod As Char
    Local nI As Numeric
    Local nJ As Numeric
    Local nMinAverDSValue As Numeric
    Local nAverDSValue := 0
    Local nYearsAverages := {0, 0}
    Local aYearsPeriods := {{}, {}}
    Local aPeriods := {}

    Local cRUSAvDSDaysCodFol := aCodFol[1750, 1]
    Local cRUSAvDSMoneyCodFol := aCodFol[1751, 1]

    Local aBaseYears := {Year(dBaseDate) - 2, Year(dBaseDate) - 1} // Simple case, can be more complicated
    Local nBaseMonth := 0

    Local aFSSLimits := {GetFSSLimit(AllTrim(Str(aBaseYears[1]))), GetFSSLimit(AllTrim(Str(aBaseYears[2])))}

    Local nTwoYearsDays := GetTwoYearsDays()

    // Fill aray by previous periods (months)
    For nI := 1 To 2
        nBaseMonth := 0
        For nJ := 1 To 12
            nBaseMonth += 1

            cPeriod := Str(aBaseYears[nI], 4) + StrZero(nBaseMonth, 2)

            AAdd(aPeriods, cPeriod)
            oMonths:Set(cPeriod, {0, 0})
        Next nJ
    Next nI

    // Check payments from opened period
    GetSRCAvRecords(cMat, aPeriods, cRUSAvDSDaysCodFol, cRUSAvDSMoneyCodFol, @oMonths)

    // Check payments from closed periods
    GetSRDAvRecords(cMat, aPeriods, cRUSAvDSDaysCodFol, cRUSAvDSMoneyCodFol, @oMonths)

    // Separate periods by years
    oMonths:List(aPeriods)
    For nI := 1 To Len(aPeriods)
        If Val(SubStr(aPeriods[nI][1], 1, 4)) == aBaseYears[1]
            AAdd(aYearsPeriods[1], aPeriods[nI])
        Else
            AAdd(aYearsPeriods[2], aPeriods[nI])
        EndIf
    Next nI

    // Calculate sum for each year
    For nI := 1 To 2
        For nJ := 1 To Len(aYearsPeriods[nI])
            nYearsAverages[nI] += aYearsPeriods[nI][nJ][2][2]
        Next nJ
        // Correct if year sum more than FSS limit
        If nYearsAverages[nI] > aFSSLimits[nI]
            nYearsAverages[nI] := aFSSLimits[nI]
        EndIf
    Next nI

    // Calculate daily average
    nAverDSValue := (nYearsAverages[1] + nYearsAverages[2]) / nTwoYearsDays

    // Calculate minimal daily average
    nMinAverDSValue := GetMinimalWage(AllTrim(Str(Year(dBaseDate)))) * 24 / nTwoYearsDays

    // Correct if daily average less than minimal one
    If nAverDSValue < nMinAverDSValue
        nAverDSValue := nMinAverDSValue
    EndIf

Return nAverDSValue

/*
{Protheus.doc} GetTwoYearsDays()
    Returns average days number in two years (S208 table)

    @type Function
    @params
    @return nDays,    Numeric,    Average number of days (by government decree)
    @author dtereshenko
    @since 2020/08/12
    @version 12.1.23
*/
Static Function GetTwoYearsDays()
    Local nDays As Numeric

    DbSelectArea("RCC")

    If DbSeek(FWXFilial("RCC") + "S208")
        nDays := Val(SubStr(RCC->RCC_CONTEU, 6, 3))
    EndIf

    DbCloseArea()

Return nDays

/*
{Protheus.doc} GetFSSLimit()
    Returns maximum amount of FSS payments by year (S001)

    @type Function
    @params cYear,       Char,       Required year
    @return nFSSLimit,   Numeric,    Maximum amount of FSS payments
    @author dtereshenko
    @since 2020/08/13
    @version 12.1.23
*/
Static Function GetFSSLimit(cYear As Char)
    Local cRccConteo As Char
    Local nFSSLimit As Numeric

    cRccConteo := fRUGetRccConteo("S001", cYear)

    nFSSLimit := Val(SubStr(cRccConteo, 13, 12))

Return nFSSLimit

/*
{Protheus.doc} GetYearDaysNumber(cYear as Char)
    Returns number of days in year

    @type Function
    @params cYear,   Char,       Required year
    @return nDays,   Numeric,    Number of days
    @author dtereshenko
    @since 2020/08/13
    @version 12.1.23
*/
Function GetYearDaysNumber(cYear as Char)
    Local nDays As Numeric

    nDays := SToD(cYear + "1231") - SToD(cYear + "0101")

Return nDays

/*
{Protheus.doc} GetMinimalWage(cYear as Char)
    Returns minimal month wage in transfered year (S004)

    @type Function
    @params cYear,      Char,      Required year
    @return nMinWage,   Numeric,   Minimal month wage
    @author dtereshenko
    @since 2020/08/12
    @version 12.1.23
*/
Static Function GetMinimalWage(cYear as Char)
    Local cRccConteo As Char
    Local nMinWage As Numeric

    cRccConteo := fRUGetRccConteo("S004", cYear)

    nMinWage := Val(SubStr(cRccConteo, 13, 12))

Return nMinWage

/*
{Protheus.doc} GetSRCAvRecords(cMat As Char, aPeriods As Array, cAvDaysCodFol As Char, cAvMoneyCodFol As Char, @oMonths As Object)
    Fills transfered oMonths hashmap with information from SRC (opened period) table about average days and average payments.

    @type Function
    @params cMat,             Char,     Employee's Reg. Number (RA_MAT)
    @params aPeriods,         Array,    Payments periods ("YYYYMM")
    @params cAvDaysCodFol,    Char,     Budget (RV_COD) for average days count
    @params cAvMoneyCodFol,   Char,     Budget (RV_COD) for average money count
    @params oMonths,          Object,   RUMap instance to be filled with payments information
    @return
    @author dtereshenko
    @since 2020/08/12
    @version 12.1.23
*/
Static Function GetSRCAvRecords(cMat As Char, aPeriods As Array, cAvDaysCodFol As Char, cAvMoneyCodFol As Char, oMonths As Object)
    Local aSavedArea := GetArea()

    DbSelectArea("SRC")
    DbSetOrder(1)

    If DbSeek(FWXFilial("SRC") + cMat)
        While !EoF() .And. SRC->RC_MAT == cMat
            If AScan(aPeriods, { |x| x == SRC->RC_PERIODO })
                If SRC->RC_PD == cAvDaysCodFol
                    oMonths:GetValue(SRC->RC_PERIODO)[1] := SRC->RC_VALOR
                ElseIf SRC->RC_PD == cAvMoneyCodFol
                    oMonths:GetValue(SRC->RC_PERIODO)[2] := SRC->RC_VALOR
                EndIf
            EndIf
            DbSkip()
        EndDo
    EndIf

    DbCloseArea()
    RestArea(aSavedArea)

Return

/*
{Protheus.doc} GetSRDAvRecords(cMat As Char, aPeriods As Array, cAvDaysCodFol As Char, cAvMoneyCodFol As Char, @oMonths As Object)
    Fills transfered oMonths hashmap with information from SRD (closed periods) table about average days and average payments.

    @type Function
    @params cMat,             Char,     Employee's Reg. Number (RA_MAT)
    @params aPeriods,         Array,    Payments periods ("YYYYMM")
    @params cAvDaysCodFol,    Char,     Budget (RV_COD) for average days count
    @params cAvMoneyCodFol,   Char,     Budget (RV_COD) for average money count
    @params oMonths,          Object,   RUMap instance to be filled with payments information
    @return
    @author dtereshenko
    @since 2020/08/12
    @version 12.1.23
*/
Static Function GetSRDAvRecords(cMat As Char, aPeriods As Array, cAvDaysCodFol As Char, cAvMoneyCodFol As Char, oMonths As Object)
    Local aSavedArea := GetArea()

    DbSelectArea("SRD")
    DbSetOrder(1)

    If DbSeek(FWXFilial("SRD") + cMat)
        While !EoF() .And. SRD->RD_MAT == cMat
            If AScan(aPeriods, { |x| x == SRD->RD_PERIODO })
                If SRD->RD_PD == cAvDaysCodFol
                    oMonths:GetValue(SRD->RD_PERIODO)[1] := SRD->RD_VALOR
                ElseIf SRD->RD_PD == cAvMoneyCodFol
                    oMonths:GetValue(SRD->RD_PERIODO)[2] := SRD->RD_VALOR
                EndIf
            EndIf
            DbSkip()
        EndDo
    EndIf

    DbCloseArea()
    RestArea(aSavedArea)

Return

/*
{Protheus.doc} fAbsences(cMat As Char, cPeriod As Char)
    Calculates and pays a disability sheet payment from allocated budget

    @type Function
    @params cMat,     Char,       Employee's Reg. Number (RA_MAT)
            cPeriod   Char,       Required period (YYYYMM)
    @return
    @author dtereshenko
    @since 2020/09/02
    @version 12.1.23
*/
Function fAbsences(cMat As Char, cPeriod As Char)
    Local aDSAbsenceTypes As Array
    Local aSavedArea := GetArea()
    Local aAbsences := {}
    Local nExpDays := 0
    Local nExpYears As Numeric
    Local nExpCoef As Numeric
    Local nAverDSValue As Numeric
    Local nMinAverDSValue As Numeric
    Local nDSDays As Numeric
    Local nDSValue As Numeric
    Local nI As Numeric

    // Fill absences types
    aDSAbsenceTypes := {"003", "004", "006", "007", "008", "009", "010", "011", "017", "019", "020", "021", "022", "023", "024", "025", "026", "027", "028", "029"}

    // Get average day earnings
    nAverDSValue := fRUDisShCal(cMat, SToD(cPeriod + "01"), RUMap():New())
    nMinAverDSValue := GetMinimalWage(SubStr(cPeriod, 1, 4)) * 24 / 730

    // Iterating through employees experience-related references and calculate full work experience
    DbSelectArea("F6H")
    DbSetOrder(2) // F6H_FILIAL+F6H_MAT

    If DbSeek(FWXFilial("F6H") + cMat)
        While !EoF() .And. F6H->F6H_MAT == cMat
            If AScan(WORK_EXPERIENCE_REFTYPES, { |x| x == AllTrim(F6H->F6H_REFTYP) })
                If Empty(F6H->F6H_END)
                    nExpDays += (dDataBase - F6H->F6H_START)
                Else
                    nExpDays += (F6H->F6H_END - F6H->F6H_START)
                EndIf
            EndIf
            DbSkip()
        EndDo
    EndIf

    DbCloseArea()

    // Calculate work experience coefficient
    nExpYears := nExpDays / 365.25

    Do Case
        Case nExpYears >= 0.5 .And. nExpYears < 5
            nExpCoef := 0.6
        Case nExpYears >= 5 .And. nExpYears < 8
            nExpCoef := 0.8
        Case nExpYears >= 8
            nExpCoef := 1
        Otherwise
            nAverDSValue := nMinAverDSValue
            nExpCoef := 1
    EndCase

    If nAverDSValue * nExpCoef < nMinAverDSValue
        nExpCoef := 1
    EndIf

    // Collect all DS-related absences within transfered period
    DbSelectArea("SR8")
    DbSetOrder(1) // R8_FILIAL + R8_MAT + DTOS(R8_DATAINI)

    If DbSeek(FWXFilial("SR8") + cMat)
        While !EoF() .And. SR8->R8_MAT == cMat
            If AScan(aDSAbsenceTypes, { |x| x == SR8->R8_TIPOAFA }) .And. Substr(DToS(SR8->R8_DATAFIM), 1, 6) == cPeriod
                AAdd(aAbsences, {SR8->R8_TIPOAFA, SR8->R8_DATAINI, SR8->R8_DATAFIM})
            EndIf
            DbSkip()
        EndDo
    EndIf

    DbCloseArea()
    RestArea(aSavedArea)

    // Calculate and pay from allocated budget (will be much more complicated)
    For nI := 1 To Len(aAbsences)
        nDSDays := aAbsences[nI][3] - aAbsences[nI][2] + 1
        nDSValue := nDSDays * nAverDSValue * nExpCoef

        Do Case
            Case aAbsences[nI][1] == "004" // Temporary disability
                If nDSDays > 3
                    FGeraVerba(aCodFol[41, 1], 3 * nAverDSValue * nExpCoef) // Emloyer's payment
                    FGeraVerba(aCodFol[1752, 1], (nDSDays - 3) * nAverDSValue * nExpCoef) // FSS payment
                Else
                    FGeraVerba(aCodFol[41, 1], nDSValue)
                EndIf
            Case aAbsences[nI][1] == "006" // Maternity
                FGeraVerba(aCodFol[40, 1], nDSValue)
        EndCase

    Next nI

    FGeraVerba(aCodFol[1753, 1], nExpDays) // Insurance experience in days at the time of payment

Return

/*
{Protheus.doc} fRUGetFSS()
    Function for retrieving array of SRV codes required for average disability sheet calculation

    @type Function
    @params
    @return aSRVAverages,    Array,    Array for SRV codes
    @author dtereshenko
    @since 2020/09/03
    @version 12.1.23
*/
Function fRUGetFSS()
    Local cSRVFilial := FWXFilial("SRV")
    Local cRevenueTipoCod := "1"
    Local aSRVFSSCodes := {}

    DbSelectArea("SRV")
    DbSetOrder(4) // RV_FILIAL + RV_TIPOCOD + RV_COD

    If DbSeek(cSRVFilial + cRevenueTipoCod, .T.)
        While !EoF() .And. SRV->RV_FILIAL == cSRVFilial
            If SRV->RV_INSS == "S"
                AAdd(aSRVFSSCodes, SRV->RV_COD)
            EndIf
            dbSkip()
        EndDo
    EndIf

    DbCloseArea()

Return aSRVFSSCodes

/*
{Protheus.doc} fRUGetBT()
    Function for retrieving array of SRV codes required for average business trip calculation

    @type Function
    @params
    @return aSRVAverages,    Array,    Array for SRV codes
    @author iprokhorenko
    @since 2020/09/08
    @version 12.1.23
*/
Function fRUGetBT()
    Local cSRVFilial := FWXFilial("SRV")
    Local cRevenueTipoCod := "1"
    Local aSRVBTCodes := {}

    DbSelectArea("SRV")
    DbSetOrder(4) // RV_FILIAL + RV_TIPOCOD + RV_COD

    If DbSeek(cSRVFilial + cRevenueTipoCod, .T.)
        While !EoF() .And. SRV->RV_FILIAL == cSRVFilial
            If SRV->RV_AVERIC == "AV"
                AAdd(aSRVBTCodes, SRV->RV_COD)
            EndIf
            dbSkip()
        EndDo
    EndIf

    DbCloseArea()

Return aSRVBTCodes


/*{Protheus.doc} fRUGetBTDay
    Return in hours the number of workdays in the current period minus any workdays missing. 

    @type  Function
    @author vselyakov
    @since 2020/09/07
    @version 12.1.23
    @param cMat, Character, Employee personnel number
           dPerStart, Date, Start date of period
           dPerEnd, Date, End date of period
    @return nResult, Numeric, Working hours of employee.
    @example 
        fRUGetBTDay('000019', STOD('20200316'), STOD('20200322'))
        fRUGetBTDay('000019', STOD('20200301'), STOD('20200315'))
        fRUGetBTDay('000019', STOD('20200301'), STOD('20200331'))
*/
Function fRUGetBTDay(cMat As Char, dPerStart As Date, dPerEnd As Date)
    Local nEmpHrs      As Numeric // Working hours per day of employee.
    Local cProces      As Character
    Local aFShedule    As Array
    Local nWCount      As Numeric
    Local dCalcDate    As Date
    Local nDays        As Numeric 
    Local nResult      As Numeric
    Local aCurArea     As Array
    Local oStatement   As Object
    Local cQuery       As Character
    Local cAlias       As Character
    Local nI           As Numeric

    Default dPerStart := dDataBase
    Default dPerEnd   := dDataBase

    aCurArea := GetArea()
    nEmpHrs  := 0
    nDays    := 0
    nResult  := 0
    aFShedule := {}

    // Get work hours per day and work shedule of employee.
    DbSelectArea("SRA")
    DbSetOrder(1) // RA_FILIAL+RA_MAT+RA_NOME
    DbGoTop()

    If DbSeek(FWXFilial("SRA") + cMat)
        While !EOF() .And. SRA->RA_MAT == cMat
            nEmpHrs := SRA->RA_HRSDIA
            cProces := SRA->RA_PROCES
            DbSkip()
        EndDo
    EndIf

    DbCloseArea()

    // Get list of work days.
    oStatement := FWPreparedStatement():New()
    cQuery := " SELECT RCG_DIAMES AS DIAMES, RCG_TIPDIA AS TIPDIA FROM " + RetSQLName("RCG") + " WHERE "
    cQuery += " RCG_PROCES=? "
    cQuery += " AND (RCG_DIAMES BETWEEN ? AND ?) "
    cQuery += " AND D_E_L_E_T_=' ' "

    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, cProces)
    oStatement:SetString(2, DTOS(dPerStart))
    oStatement:SetString(3, DTOS(dPerEnd))

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery(), "cAlias")

    DBSelectArea(cAlias)
    DBGoTop()

    // Subtract the number of days of absence.
    WHILE !EOF()
        AAdd(aFShedule, { (cAlias)->DIAMES, (cAlias)->TIPDIA })
        DBSkip()
    ENDDO

    DbCloseArea()

    // Get working days without absences.
    nWCount := Len(aFShedule)

    For nI := 1 To nWCount
        If (aFShedule[nI][2] == "1")
            nDays += 1
        EndIf
    Next nI
    
    // SQL query for get days count of all types absence.
    oStatement := FWPreparedStatement():New()
    cQuery := " SELECT R8_DATAINI AS DINIT, R8_DATAFIM AS DFIN FROM " + RetSQLName("SR8") + " WHERE "
    cQuery += " R8_MAT=? "
    cQuery += " AND ((R8_DATAINI BETWEEN ? AND ?) OR (R8_DATAFIM BETWEEN ? AND ?)) "
    cQuery += " AND D_E_L_E_T_=' ' "

    oStatement:SetQuery(cQuery)
    oStatement:SetString(1, cMat)
    oStatement:SetString(2, DTOS(dPerStart))
    oStatement:SetString(3, DTOS(dPerEnd))
    oStatement:SetString(4, DTOS(dPerStart))
    oStatement:SetString(5, DTOS(dPerEnd))

    cAlias := MPSysOpenQuery(oStatement:GetFixQuery(), "cAlias")

    DBSelectArea(cAlias)
    DBGoTop()

    // Subtract the number of days of absence.
    WHILE !EOF()
        dCalcDate := STOD((cAlias)->DINIT)

        While (dCalcDate <= STOD((cAlias)->DFIN))
            
            For nI := 1 To nWCount
                If (aFShedule[nI][1] == DTOS(dCalcDate) .AND. aFShedule[nI][2] == "1")
                    nDays -= 1
                EndIf
            Next nI

            dCalcDate += 1
        EndDo

      DBSkip()
    ENDDO

    // Calculate working hours.
    nResult := nDays * nEmpHrs

    // Destroy FWPreparedStatement object.
    oStatement:Destroy()
    FwFreeObj(oStatement)    

    RestArea(aCurArea)
Return nResult
