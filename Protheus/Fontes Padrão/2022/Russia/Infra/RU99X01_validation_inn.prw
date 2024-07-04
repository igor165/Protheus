#include 'protheus.ch'
#include 'RU99VALSTR.CH'

//validation OGRN. By SA

function RU99X01OGRN(cInput,cType)
local lRet as logical
local nSize as integer

nSize := len(allTrim(cInput))
lRet := .F.

if cType == "1" .and. nSize == 15
	lRet := .T.
endif

if cType == "2" .and. nSize == 13
	lRet := .T.
endif

return lRet

//validation OKPO. By SA

function RU99X01OKPO(cInput,cType)
local lRet as logical
local nSize as integer

nSize := len(allTrim(cInput))
lRet := .f.

if cType == "1" .and. nSize == 10
	lRet := .t.
endif

if cType == "2" .and. nSize == 8
	lRet := .t.
endif

return lRet


//validation inn. 07.09.2017 b4. autor Nikitenko Artem.

function RU99X01INN(cInputInn,cFaceUG)

local aInn as array 
local nLongInn as Numeric 
local nModChek as Numeric 
local nCount1 as Numeric 
local nCount2 as Numeric 
local nValAmount as Numeric 
local aValidList as array 
local nAmountTFV as Numeric 
local lRet as logical

nLongInn := 0
nModChek := 0
nValAmount := 0
nAmountTFV := 0
aInn := array(12)
aValidList := {0,3,7,2,4,10,3,5,9,4,6,8,0}

nLongInn := (len(allTrim(cInputInn)))
if cFaceUG=="3"
	lRet := .T.
else
	if nLongInn != 0
		if nLongInn < 10 .or. nLongInn == 11 .or. nLongInn > 12
 				Help( " ", 1, "FLRU99X04_VINN" ) //"False inn"
			lRet := .F.
			nModChek:=2
		else
			if nLongInn <= 10 .and. cFaceUG == "2"
				nAmountTFV := 1
				nModChek := 1
			else
				if nLongInn == 12 .and. cFaceUG == "1"
					nAmountTFV := 1
					nModChek := 0
				else
 				Help( " ", 1, "FLRU99X04_VINN" ) //"False inn"
					nModChek := 2
					lRet :=  .F.
				endif
			endif
			for nCount1 := 1+nModChek to 2
				
				nValAmount:=0
		
				for nCount2 := 1 to nLongInn
					aInn [nCount2] := (NOROUND(val(alltrim(Substr(cInputInn,nCount2,1))), 0)) 
					if nCount2<(nLongInn) 
						nValAmount := nValAmount + int(aInn[nCount2]) * aValidList[nCount2-nCount1+3+nModChek*2]
					endif
					if nCount2=nLongInn+nCount1-2 
						if  aInn[nCount2] == ((nValAmount % 11) % 10) 
							nAmountTFV := nAmountTFV + 1
						else
							nAmountTFV := nAmountTFV - 1 
						ENDIF
					Endif
				Next nCount2
			Next nCount1
			if (nAmountTFV < 2) .and. (nModChek != 2)
 				Help( " ", 1, "FLRU99X04_VINN" ) //"False inn"
				lRet := .F.
			endif
		endif
		if nAmountTFV == 3 .and. nLongInn == 12 //"True inn"
			lRet := .T.
		else
			if nAmountTFV == 2 .and. nLongInn == 10 //"True inn"
				lRet :=  .T.
			endif
		endif
	else
		lRet :=  .T.
	endif
endif

return lRet

/*/
{Protheus.doc} RU99X02SNILS(cSnils As Char)
    Validation of the SNILS number

    SNILS should consist of 11 digits, while there should not be a 3-fold sequence of repeating digits.
    And the last 2 must correspond to the checksum according to the rule

    @type Function
    @params cSnils,    Char,     SNILS number to check it
    @author Anna Fedorova
    @since 08/29/2019
    @version 12.1.23
    @return lResult,    Logical,    Validation result
/*/
Function RU99X02SNILS(cSnils As Char)
    Local nI As Numeric
    Local lResult As Logical
    Local nSumm As Numeric
    Local aSnils As Array

    nSumm := 0
    aSnils := {}

    cSnils := StrTran(cSnils, "-", "")
    cSnils := StrTran(cSnils, " ", "")

    lResult := Len(cSnils) == 11 .And. Len(AllTrim(Str(Val("1" + cSnils)))) == 12 // Check that snls do not contain characters not numbers

    If lResult
        For nI := 1 To 9
            If lResult
                AAdd(aSnils, Val(SubStr(cSnils, nI, 1)))
                nSumm += Val(SubStr(cSnils, nI, 1)) * (10 - nI) // The checksum must correspond to the last 2 digits of SNILS

                // Check that there are no 3 repeating characters in the SNILS code
                If nI >= 3
                    If aSnils[nI] == aSnils[nI-1] .And. aSnils[nI] == aSnils[nI-2]
                        lResult := .F.
                    EndIf
                EndIf
            EndIf
        Next nI
    EndIf

    If lResult
        lResult := ( nSumm < 100 .And. nSumm == Val(SubStr(cSnils, 10, 2)) ) .Or. ;
            ( nSumm == 100 .And. Val(SubStr(cSnils, 10, 2)) == 00 ) .Or. ;
            ( nSumm > 100 .And. nSumm % 101 == Val(SubStr(cSnils, 10, 2)) )
    EndIf

    If !lResult
        Help( " ", 1, "FLRU99X02_VINN" )
    EndIf

Return lResult

/*/
{Protheus.doc} RU99X04MID(cMID As Char)
    Validation of the Military ID series and number

    Series: 2 Cyrillic letters
    Number: 7 digits

    @type Function
    @params cSnils,    Char,     Military ID series and number to check it
    @author Anna Fedorova
    @since 08/29/2019
    @version 12.1.23
    @return lResult,    Logical,    Validation result
/*/
Function RU99X03MID(cMID As Char)
    Local lResult As Logical
    Default cMid := ""

    lResult := .F.
    cMID := StrTran(cMID, CHR(185), "") // Symbol of number

    If !Empty(cMid)
        cMID := StrTran(cMID, "#", "")
        cMID := StrTran(cMID, " ", "")

        If Len(cMID) == 9 .And. Len(AllTrim(Str(Val("1" + Substr(cMID, 3, 7))))) == 8 // Length check and the last 7 characters are digits
            If 191 < ASC(SubStr(cMID, 1, 1)) .And. ASC(SubStr(cMID, 1, 1)) < 224
                 If 191 < ASC(SubStr(cMID, 2, 1)) .And. ASC(Substr(cMID, 2, 1)) < 224 // Check that the first 2 characters are cyrillic letters
                    lResult := .T.
                EndIf
            EndIf 
        EndIf

        If !lResult
            Help( " ", 1, "FLRU99X03_VINN" )
        EndIf
    EndIf

Return lResult

/*{Protheus.doc} RU99X05ACC(cAccount As Char, cBIK As Char)
    Validation of given Bank Account Number according to transfered Russian Bank ID (BIK)

    In case of transfering foreign or unknown Bank ID function's result will be always True(.T.) if non-empty Account Number was transfered

    @type Function
    @params cAccount,    Char,    Bank Account number to check it
            cBankID,     Char,    BIK (Russian Bank ID)
    @author dtereshenko
    @since 02/05/2020
    @version 12.1.23
    @return lResult,    Logical,    Validation result
*/
Function RU99X05ACC(cAccount As Char, cBIK As Char)
    Local lResult As Logical
    Local lRussianBIK As Logical
    Local cForeignBIKField As Char
    Local nI As Numeric
    Local nCheckSum As Numeric
    Local aAccount As Array
    Local aBIK As Array
    Local aCoefficients As Array

    Default cBIK := ""
    Default cAccount := ""

    aAccount := {}
    aBIK := {}

    nCheckSum := 0
    aCoefficients := {7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1, 3, 7, 1}

    cAccount := AllTrim(cAccount)
    cBIK := AllTrim(cBIK)

    lResult := .F.
    lRussianBIK := .F.

    cForeignBIKField := AllTrim(Posicione("F45", 1, xFilial("F45") + cBIK, "F45_FOREIG"))
    lRussianBIK := ( cForeignBIKField == "2" )

    If lRussianBIK
        If Len(cAccount) == 20 .And. Len(cBIK) == 9
            For nI := 1 To Len(cAccount)
                If Type(SubStr(cAccount, nI, 1)) == "N"
                    AAdd(aAccount, Val(SubStr(cAccount, nI, 1)))
                EndIf
            Next nI
            For nI := 1 To Len(cBIK)
                If Type(SubStr(cBIK, nI, 1)) == "N"
                    AAdd(aBIK, Val(SubStr(cBIK, nI, 1)))
                EndIf
            Next nI

            If Len(aAccount) == 20 .And. Len(aBIK) == 9
                ASize(aAccount, 23)
                For nI := 1 To 3
                    AIns(aAccount, nI)
                    aAccount[nI] := aBIK[Len(aBIK) - 3 + nI] // Last 3 digits of BIK to the beginning of Account Number
                Next nI

                For nI := 1 To Len(aAccount)
                    nCheckSum += aAccount[nI] * aCoefficients[nI]
                Next nI

                lResult := ( nCheckSum % 10 == 0 )
            EndIf
        EndIf
    Else
        lResult := !Empty(cAccount)
        Help( " ", 1, "FLRU99X05_VINN" ) // Unknown or Foreign Bank ID - Bank Account Number can't be validated
    EndIf

    If !lResult
        Help( " ", 1, "FLRU99X06_VINN" ) // The Bank Account Number is invalid - Check that the Bank Account Number is entered correctly
    EndIf

Return lResult
