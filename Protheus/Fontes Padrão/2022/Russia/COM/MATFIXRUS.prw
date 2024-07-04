/*/{Protheus.doc} RuMaFisRef
@author Alexander Salov
@since 13/12/2017
@version 1.0
@return ${return}, ${return_description}
@type function
@brief MaFisRef locilized for RUS
/*/
Function RuMaFisRef(cReferencia,cProg,xValor)

Local aArea	   := GetArea()
Local lRet 	   := .T.
Local nX       := 0
Local nY       := 0
Local cValid   := ""
Local cRefCols := ""

If MaFisFound("NF")
	If SubStr(cReferencia,1,2) == "NF"
		If lRet := MaFisVldAlt(cReferencia)
			MaFisAlt(cReferencia,xValor)
			For nY := 1 to Len(aCols)
				If MaFisFound("IT",nY)
					For nX	:= 1 to Len(aHeader)
						cValid	:= AllTrim(UPPER(aHeader[nX][6]))
						If "MAFISREF"$cValid
							nPosRef := AT('MAFISREF("',cValid) + 10
							cRefCols:=Substr(cValid,nPosRef,AT('","'+cProg+'",',cValid)-nPosRef )
							aCols[nY][nX]:= MaFisRet(nY,cRefCols)
						EndIf
					Next nX
				EndIf
			Next nY
		EndIf
	Else
		If MaFisFound("IT",N)
			If aNfItem[N][IT_DELETED] .And. IIf(Len(aCols[1])==Len(aHeader)+1,!aCols[N][Len(aHeader)+1],.F.)
				MaFisDel(N,.F.)
			EndIf
			If GdFieldPos("D1_ITEM")>0
				aNfItem[N][IT_ITEM] := aCols[N][GdFieldPos("D1_ITEM")]
			EndIf
		EndIf
		MaFisIniLoad(n)
		If lRet := MaFisVldAlt(cReferencia,n)
			MaFisAlt(cReferencia,xValor,n)
			For nX	:= 1 to Len(aHeader)
				cValid	:= AllTrim(UPPER(aHeader[nX][6]))
				If "MAFISREF"$cValid
					nPosRef := AT('MAFISREF("',cValid) + 10
					cRefCols:=Substr(cValid,nPosRef,AT('","'+cProg+'",',cValid)-nPosRef )
					aCols[n][nX]:= MaFisRet(n,cRefCols)
				EndIf
			Next nX
		EndIf
	EndIf
EndIf

Return lRet
// Russia_R5
