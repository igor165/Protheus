#INCLUDE "protheus.ch"
#INCLUDE "dbstruct.ch"
#INCLUDE "ru99x01_n.ch"
/*//
developed by: Andrey Filatov and Artem Nikitenko.
developed 21.10.2016, updated 06.04.2018
Program to represent the number of words
/*/


// nNumber - value to represent words, firstUpper = .t. or .f. - To change the first letter to uppercase
Function RU99X01(nNumber as numeric,firstUpper as logical,cGender as character)//cGender CTO->CTO_UNIGEN
	Local nQuantity	as numeric
	Local cExt as character
	nQuantity	:= 0
	cExt 		:= ""
	If noround(nNumber,0) == 0
		cExt:= AddString(cExt, STR0001) // 0 for rubles
		Return cExt
	Else
		nNumber :=noround(nNumber,0)
		
		If nNumber < 0     // Number of modulo
			nNumber = ABS(nNumber)
		EndIf
		
		If nNumber >= 1000000000000000 // If more quadrillion
			cExt:= AddString(cExt, STR0002)
			Return cExt
		EndIf
		
		If nNumber >= 1000000000000
			nQuantity := noRound(nNumber/1000000,0)//Division by more than a rounding error 10000000
			nQuantity := noRound(nQuantity/1000000,0)
			cExt := AddString(cExt,NumStringH(nQuantity,.F.)) // How many trillions of words
			If Mod(nQuantity,10) == 1 .And. Mod(nQuantity,100)!=11
				cExt := AddString(cExt, STR0003) //trillion - singular (1)
			ElseIf Mod(nQuantity,10) == 2 .And. Mod(nQuantity,100)!=12 .Or. Mod(nQuantity,10) == 3.And. Mod(nQuantity,100)!=13;
					.Or. Mod(nQuantity,10) == 4.And. Mod(nQuantity,100)!=14
				cExt := AddString(cExt, STR0004) //trillion - plural (from 2 ~ to 4)
			Else
				cExt := AddString(cExt, STR0005) //trillion - plural (from 5 ~ to 9)
			EndIf
			nNumber := round(nNumber - nQuantity * 1000000000000,0)
		EndIf
		
		If nNumber >= 1000000000
			nQuantity :=  noRound(nNumber/ 1000000,0)
			nQuantity := noRound(nQuantity/1000,0)
			cExt := AddString(cExt,NumStringH(nQuantity,.F.)) // How many billions of words
			If Mod(nQuantity,10) == 1 .And. Mod(nQuantity,100)!=11
				cExt := AddString(cExt, STR0006) // billion - singular (1)
			ElseIf Mod(nQuantity,10) == 2 .And. Mod(nQuantity,100)!=12 .Or. Mod(nQuantity,10) == 3.And. Mod(nQuantity,100)!=13;
					.Or. Mod(nQuantity,10) == 4.And. Mod(nQuantity,100)!=14
				cExt := AddString(cExt, STR0007) // billions - plural (from 2 ~ to 4)
			Else
				cExt := AddString(cExt, STR0008) // billions - plural (from 5 ~ to 9)
			EndIf
			nNumber := round(nNumber - nQuantity * 1000000000,0)
		EndIf
		
		If nNumber >= 1000000
			nQuantity :=  noRound(nNumber/1000000,0)  // How many millions
			cExt := AddString(cExt,NumStringH(nQuantity,.F.)) //How many millions of words
			If Mod(nQuantity,10) == 1 .And. Mod(nQuantity,100)!=11
				cExt := AddString(cExt, STR0009) // million - singular (1)
			ElseIf Mod(nQuantity,10) == 2 .And. Mod(nQuantity,100)!=12 .Or. Mod(nQuantity,10) == 3.And. Mod(nQuantity,100)!=13;
					.Or. Mod(nQuantity,10) == 4.And. Mod(nQuantity,100)!=14
				cExt := AddString(cExt, STR0010) // millions - plural (from 2 ~ to 4)
			Else
				cExt := AddString(cExt, STR0011) // millions - plural (from 5 ~ to 9)
			EndIf
			nNumber := round(nNumber - noRound(nNumber / 1000000,0) * 1000000,0) // For millions all done, then you need to determine nQuantity
		EndIf
		
		If nNumber >= 1000
			nQuantity :=  noRound(nNumber/1000,0) // Define nQuantity thousands
			cExt := AddString(cExt,NumStringH(nQuantity,.T.)) // Thousands of words
			If Mod(nQuantity,10) == 1 .And. Mod(nQuantity,100)!=11
				cExt := AddString(cExt, STR0012) // one thousand - singular (1)
			ElseIf Mod(nQuantity,10) == 2 .And. Mod(nQuantity,100)!=12 .Or. Mod(nQuantity,10) == 3.And. Mod(nQuantity,100)!=13;
					.Or. Mod(nQuantity,10) == 4.And. Mod(nQuantity,100)!=14
				cExt := AddString(cExt, STR0013) // thousands - plural (from 2 ~ to 4)
			Else
				cExt := AddString(cExt, STR0014) // thousands - plural (from 5 ~ to 9)
			EndIf
			nNumber := round(nNumber - noRound(nNumber / 1000,0) * 1000,0)
		EndIf
		
		If nNumber >= 0
			If cGender == "1"
				cExt := AddString(cExt, NumStringH(nNumber,.F.))
			ElseIf cGender == "2"
				cExt := AddString(cExt, NumStringH(nNumber,.T.))
			EndIf
		EndIf
	EndIf
	
	If firstUpper == .t.
		cExt :=  (UPPER(SUBSTR(cExt, 1, 1))+ SUBSTR(cExt, 2))//makes the first letter uppercase
	EndIf
Return cExt




// Returns a string representation of the number with the digit 3
Function NumStringH( nQuantity as numeric,lGender as logical)
	Local cNumber as character
	
	cNumber := ""
	
	If nQuantity >= 100
		cNumber := NumString(noRound(nQuantity/100,0)*100,lGender)
		nQuantity := nQuantity - noRound(nQuantity / 100,0) * 100
	EndIf
	
	If nQuantity >= 20
		cNumber     := addString(cNumber, NumString(noRound(nQuantity/10,0) * 10,lGender))
		nQuantity := nQuantity - noRound(nQuantity / 10,0) * 10
	EndIf
	
	cNumber := addString(cNumber, NumString(nQuantity,lGender))
	
Return cNumber




// Returns a string representation of the number
Function NumString(nNum as numeric,lGender as logical)
	Local cNumStr as character
	If nNum == 100
		cNumStr := STR0015
	ElseIf nNum == 200
		cNumStr := STR0016
	ElseIf nNum == 300
		cNumStr := STR0017
	ElseIf nNum == 400
		cNumStr := STR0018
	ElseIf nNum == 500
		cNumStr := STR0019
	ElseIf nNum == 600
		cNumStr := STR0020
	ElseIf nNum == 700
		cNumStr := STR0021
	ElseIf nNum == 800
		cNumStr := STR0022
	ElseIf nNum == 900
		cNumStr := STR0023
	ElseIf nNum == 11
		cNumStr := STR0024
	ElseIf nNum == 12
		cNumStr := STR0025
	ElseIf nNum == 13
		cNumStr := STR0026
	ElseIf nNum == 14
		cNumStr := STR0027
	ElseIf nNum == 15
		cNumStr := STR0028
	ElseIf nNum == 16
		cNumStr := STR0029
	ElseIf nNum == 17
		cNumStr := STR0030
	ElseIf nNum == 18
		cNumStr := STR0031
	ElseIf nNum == 19
		cNumStr := STR0032
	ElseIf nNum == 20
		cNumStr := STR0033
	ElseIf nNum == 30
		cNumStr := STR0034
	ElseIf nNum == 40
		cNumStr := STR0035
	ElseIf nNum == 50
		cNumStr := STR0036
	ElseIf nNum == 60
		cNumStr := STR0037
	ElseIf nNum == 70
		cNumStr := STR0038
	ElseIf nNum == 80
		cNumStr := STR0039
	ElseIf nNum == 90
		cNumStr := STR0040
	ElseIf nNum == 10
		cNumStr := STR0041
	ElseIf nNum == 9
		cNumStr := STR0042
	ElseIf nNum == 8
		cNumStr := STR0043
	ElseIf nNum == 7
		cNumStr := STR0044
	ElseIf nNum == 6
		cNumStr := STR0045
	ElseIf nNum == 5
		cNumStr := STR0046
	ElseIf nNum == 4
		cNumStr := STR0047
	ElseIf nNum == 3
		cNumStr := STR0048
	ElseIf nNum == 2
		cNumStr := IIf(lGender,STR0049,STR0050)
	ElseIf nNum == 1
		cNumStr := IIf(lGender,STR0051,STR0052)
	ElseIf	nNum == 0
		cNumStr := ""
	EndIf
	
Return  cNumStr



// Concatenation of two strings
Function addString(cString1 as character, cString2 as character)
	
	If cString1 == ""
		cFString := cString2
	ElseIf cString2 == ""
		cFString := cString1
	Else
		cFString := cString1 + " " + cString2
	EndIf
	
Return cFString



//Function for testing
Function tddPropis0(nNumber as numeric,sPropis as character,cCurCode as character )
	Local cPropis0 as character
	Local aAreaCTO as array
	Local cGender as character
	
	aAreaCTO := CTO->(GetArea())
	dbSelectArea("CTO")
	CTO->(dbSetOrder(1))
	If  dbSeek ( xFilial("CTO")+cCurCode, .T.)
		cGender:=CTO->CTO_UNIGEN
	EndIf
	cPropis0 := RU99X01(nNumber,.t.,cGender)+ " "+ Currency(nNumber,1,cCurCode)+" "+IIf(Decimal(nNumber)<10,"0"+STR(Decimal(nNumber),1),STR(Decimal(nNumber),2))+" "+ Currency(nNumber,2,cCurCode)
	conout(IIf(cPropis0==sPropis,"OK  :","FAIL:") + STR(nNumber) + "=[" + cPropis0  + "]")
	If cPropis0!=sPropis
		conout("GOOD:"+ STR(nNumber) + "=[" + sPropis + "]")
		
	EndIf
	dbCloseArea("CTO")
	RestArea( aAreaCTO )	
Return nil



//currency decline
Function Currency(nNumber as numeric,nCurren as numeric, cCurCode as character )//CTO->CTO_MOEDA
	Local cCurRub as character
	Local cCurKop as character
	Local cResult as character
	Local cUnisin as character
	Local cUniplu as character
	Local cUnplu2 as character
	Local aAreaCTO as array
	
	aAreaCTO := CTO->(GetArea())
	dbSelectArea("CTO")
	CTO->(dbSetOrder(1))
	If  dbSeek ( xFilial("CTO")+cCurCode, .T.)
		cUnisin:= CTO->CTO_UNISIN
		cUniplu:= CTO->CTO_UNIPLU
		cUnplu2:= CTO->CTO_UNPLU2
		cDecsin:= CTO->CTO_DECSIN
		cDecplu:= CTO->CTO_DECPLU
		cDeplu2:= CTO->CTO_DEPLU2
	EndIf
	cCurRub 		:= ""
	cCurKop 		:= ""
	cResult			:= ""
	
	If nCurren == 1
		nNumber := DEC_CREATE(nNumber,20,2)
		If noround(DEC_Mod(nNumber,DEC_CREATE( 10, 20, 2 )),0) == 1.And. noround(Mod(nNumber,DEC_CREATE( 100, 20, 2 )),0)!=11
			cCurRub += AllTrim(cUnisin)//"рубль"  // 1 ruble CTO->CTO_UNISIN
		ElseIf noround(Mod(nNumber,DEC_CREATE( 10, 20, 2 )),0) == 2 .And. noround(Mod(nNumber,DEC_CREATE( 100, 20, 2 )),0)!=12;
				.Or. noround(Mod(nNumber,DEC_CREATE( 10, 20, 2 )),0) == 3.And. noround(Mod(nNumber,DEC_CREATE( 100, 20, 2 )),0)!=13;
				.Or. noround(Mod(nNumber,DEC_CREATE( 10, 20, 2 )),0) == 4.And. noround(Mod(nNumber,DEC_CREATE( 100, 20, 2 )),0)!=14
			cCurRub += AllTrim(cUniplu)// rubles - from 2 to 4 CTO->CTO_UNIPLU
		Else
			cCurRub += AllTrim(cUnplu2)// rubles - from 5 to 9 CTO->CTO_UNPLU2
		EndIf
		cResult:= cCurRub
	ElseIf nCurren == 2
		nNumber := DEC_CREATE(nNumber*100,20,2)
		If noround(DEC_Mod(nNumber,DEC_CREATE( 10, 20, 2 )),0) == 1.And. noround(Mod(nNumber,DEC_CREATE( 100, 20, 2 )),0)!=11
			cCurKop += AllTrim(cDecsin)// 1 penny CTO->CTO_DECSIN
		ElseIf noround(Mod(nNumber,DEC_CREATE( 10, 20, 2 )),0) == 2 .And. noround(Mod(nNumber,DEC_CREATE( 100, 20, 2 )),0)!=12;
				.Or. noround(Mod(nNumber,DEC_CREATE( 10, 20, 2 )),0) == 3.And. noround(Mod(nNumber,DEC_CREATE( 100, 20, 2 )),0)!=13;
				.Or. noround(Mod(nNumber,DEC_CREATE( 10, 20, 2 )),0) == 4.And. noround(Mod(nNumber,DEC_CREATE( 100, 20, 2 )),0)!=14
			cCurKop += AllTrim(cDecplu)// penny from 2 to 4 CTO->CTO_DECPLU
		Else
			cCurKop += AllTrim(cDeplu2)// penny from 5 to 9 CTO->CTO_DEPLU2
		EndIf
		cResult:= cCurKop
	EndIf
	dbcloseArea("CTO")
	RestArea( aAreaCTO )
Return cResult


//He considers penny (cents)
Function Decimal(nNumber as numeric)
	Local nPenny as numeric
	nPenny := 0
	nNumber := nNumber*100
	nPenny := round(Mod(nNumber,100),0)
	If nPenny==100
		nPenny:=0
	EndIf
Return nPenny

//merge branch 12.1.19
// Russia_R5
