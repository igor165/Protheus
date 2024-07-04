#include "protheus.ch"

Function PSec2Text(nTime,nStr)
Local nHour
Local nMinute
Local nSecond
Local cTime
Local nTemp

DEFAULT nTime := 0
DEFAULT nStr := 2

nTemp := Int(nTime/60)

nHour := Int(nTemp/60)

nMinute := nTemp - (nHour*60)

nSecond := nTime - ((nHour*3600)+(nMinute*60))

cTime := StrZero(nHour,nStr,0)+":"+StrZero(nMinute,2,0)+":"+StrZero(nSecond,2,0)

Return cTime

Function PText2Sec(cTime)
Local nHour
Local nMinute
Local nSecond
Local nTime

DEFAULT cTime := "00:00:00"

nHour := Val(Subs(cTime,1,2))

nMinute := Val(Subs(cTime,4,2))

nSecond := Val(Subs(cTime,7,2))

nTime := (nHour*3600)+(nMinute*60)+nSecond

Return nTime

Function PRetRange(nFreq,cFTipo)

If ( cFTipo == "1" )
	cRet := PSec2Text(nFreq*60)
ElseIf ( cFTipo == "2" )
	cRet := PSec2Text(nFreq*3600)
ElseIf ( cFTipo == "3" )
	cRet := PSec2Text(nFreq*86400)
EndIf
Return cRet

Function PSumTime(cTime,cRange)
Local cRet
Local nHour
Local nMinute
Local nSecond
Local dDate
Local nOnlyDay
Local nTimesDay := GetMv("MV_HHNTIME",,1)
DEFAULT  nOnlyDay := Val(GetSrvProfString("HandHeldDay","1"))

//                1
//		 1234567890123456
//cTime: aaaammddhh:mm:ss                   	
//cRange: hh:mm:ss

dDate := Stod(Subs(cTime,1,8))

If nOnlyDay = 1 // Soma o intervalo 
	nHour := Val(Subs(cTime,9,2))+Val(Subs(cRange,1,2))
	nMinute := Val(Subs(cTime,12,2))+Val(Subs(cRange,4,2))
	nSecond := Val(Subs(cTime,15,2))+Val(Subs(cRange,7,2))
ElseIf nOnlyDay = 2  // ALtera apenas o dia
	nHour := Val(Subs((PTALIAS)->P_TIME,9,2))
	nMinute := Val(Subs((PTALIAS)->P_TIME,12,2))
	nSecond := Val(Subs((PTALIAS)->P_TIME,15,2))
ElseIf nOnlyDay = 3 // Gera n Vezes ao dia
	nInter := 24 / nTimesDay
	nHour := Val(Subs((PTALIAS)->P_TIME,9,2))+nInter
	nMinute := Val(Subs((PTALIAS)->P_TIME,12,2))
	nSecond := Val(Subs((PTALIAS)->P_TIME,15,2))
EndIf

nTemp := Int(nSecond/60)

nMinute += nTemp

nSecond -= nTemp*60

nTemp := Int(nMinute/60)

nHour += nTemp

nMinute -= nTemp*60

//verifica se hora passou das 24 para reiniciar
If nOnlyDay = 1 .Or. nOnlyDay = 3
	If ( nHour >= 24 )
		nHour := (Int(nHour/24)-1) + (nHour - 24)
		dDate += 1
	EndIf
ElseIf nOnlyDay = 2
	dDate += 1
EndIf
cRet := Dtos(dDate)+StrZero(nHour,2,0)+":"+StrZero(nMinute,2,0)+":"+StrZero(nSecond,2,0)

Return cRet
