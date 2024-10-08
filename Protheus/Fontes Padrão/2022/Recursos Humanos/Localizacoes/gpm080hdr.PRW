#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������Ŀ
�Fun��o    �GPM080HDR �Autor�Microsiga Software       � Data �20/02/2006�
�����������������������������������������������������������������������Ĵ
�Descri��o �Cambiar informaciones generadas por el archivo de neto      �
�����������������������������������������������������������������������Ĵ
�Uso       �Generico                                                    �
�����������������������������������������������������������������������Ĵ
�            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           �
�����������������������������������������������������������������������Ĵ
�Programador � Data   � BOPS �  Motivo da Alteracao                     �
�����������������������������������������������������������������������Ĵ
�            �        �      �                                          �
�������������������������������������������������������������������������/*/
User Function GPM080HDR

Local aLines	:= {}

Local cString	:= ""
Local cTotal	:= ""
Local cNewLine	:= ""
Local cFind 	:= "#"

Local nX
Local nY
Local nTam		:= 0
Local nPosIni
Local nArqLiq 	:= 0

If Type("nDecTotal") == "U"
	Private nDecTotal:= 0
EndIf

fClose(nHdlSaida)

/*
��������������������������������������������������������������Ŀ
� Retornar las lineas del archivo generado en array.           �
����������������������������������������������������������������*/
aLines := FileToArr( cArqSaida )

/*
��������������������������������������������������������������Ŀ
� Cambiar la informacion ### por la variable nTotal.           �
����������������������������������������������������������������*/
For nX := 1 To Len( aLines )
	cString := aLines[ nX ]
	nPosIni := At( cFind, cString )
	If nPosIni > 0
		cNewLine := Substr( cString, 1, nPosIni-1 )
		For nY := nPosIni To Len( cString )
			If Substr( cString, nY, 1 ) == cFind
				nTam++
			Else
				Exit
			EndIf
		Next nY
		If cPaisLoc $ "PER|MEX|COL|EQU"
			cTotal := StrZero( nTotal, nTam, nDecTotal)
		Else
			cTotal := StrZero( nTotal, nTam)
		EndIf
		cNewLine += cTotal + Substr( cString, nY, Len(cString))
		aLines[nX] := cNewLine
		Exit
	EndIf
Next nX

/*
��������������������������������������������������������������Ŀ
� Grabar en el Archivo Texto.                                  �
����������������������������������������������������������������*/
nArqLiq := FCreate(cArqSaida)

cString := ""
For nX := 1 To Len( aLines )
	cString := aLines[nX] + Chr(13)+Chr(10)
	Fwrite(nArqLiq,cString,Len(cString))
Next nX 

Return( .t. )
