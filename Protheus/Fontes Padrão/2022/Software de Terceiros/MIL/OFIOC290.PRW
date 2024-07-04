// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 10     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "Protheus.ch"
#Include "OFIOC290.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOC290 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 25/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Graficos PAINEL ON LINE                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOC290(cPAREmp,aPAREmp,aPARPre,aPARTGT,aPARTGB,aPARTGO,aPARTGV,dPARDtI,dPARDtF,nPARNro)
Local lEmpr := .f.
Local aFWArrFilAtu := FWArrFilAtu()
Local aObjects   := {} , aInfo := {}, aPos := {}
Local aSizeHalf  := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Private cUsuPerm := "*" // Graficos permitidos do Usuario visualizar
Private cEmpr   := ""
Private aVetEmp := {}
Private lMarcar := .f.
Private aEmpr   := {}
Private dDtIni  := ( dDataBase - day(dDataBase) ) + 1
Private dDtFin  := dDataBase
Private nNro    := 999
Private nx      := 1
Private lPriVez := .t.
Private cTit    := ""
Private nGraf   := 4
Private cTipGraf := ""
Private aGrafico := {}
Private cPrefixo := STR0002
Private aPrefixo := {STR0002,STR0003,STR0004,STR0005}
Private cTpGrafT := cTpGrafB := cTpGrafO := cTpGrafV := ""
Private aTpGrafT := {"",;
					"BAL01 - "+STR0006,;
					"BAL02 - "+STR0007,;
					"BAL03 - "+STR0008,;
					"BAL04 - "+STR0009,;
					"BAL05 - "+STR0010,;
					"BAL06 - "+STR0011,;
					"OFI01 - "+STR0012,;
					"OFI02 - "+STR0013,;
					"OFI03 - "+STR0014,;
					"OFI04 - "+STR0015,;
					"OFI05 - "+STR0016,;
					"VEI01 - "+STR0017,;
					"VEI02 - "+STR0018,;
					"VEI03 - "+STR0019,;
					"VEI04 - "+STR0020,;
					"VEI05 - "+STR0021,;
					"VEI06 - "+STR0022,;
					"VEI07 - "+STR0023,;
					"VEI08 - "+STR0024}
Private aTpGrafB := {"",;
					"BAL01 - "+STR0006,;
					"BAL02 - "+STR0007,;
					"BAL03 - "+STR0008,;
					"BAL04 - "+STR0009,;
					"BAL05 - "+STR0010,;
					"BAL06 - "+STR0011}
Private aTpGrafO := {"",;
					"OFI01 - "+STR0012,;
					"OFI02 - "+STR0013,;
					"OFI03 - "+STR0014,;
					"OFI04 - "+STR0015,;
					"OFI05 - "+STR0016}
Private aTpGrafV := {"",;
					"VEI01 - "+STR0017,;
					"VEI02 - "+STR0018,;
					"VEI03 - "+STR0019,;
					"VEI04 - "+STR0020,;
					"VEI05 - "+STR0021,;
					"VEI06 - "+STR0022,;
					"VEI07 - "+STR0023,;
					"VEI08 - "+STR0024}
Default cPAREmp := ""
Default aPAREmp := aEmpr
Default aPARPre := aClone(aPrefixo)
Default aPARTGT := aClone(aTpGrafT)
Default aPARTGB := aClone(aTpGrafB)
Default aPARTGO := aClone(aTpGrafO)
Default aPARTGV := aClone(aTpGrafV)
Default dPARDtI := dDtIni
Default dPARDtF := dDtFin
Default nPARNro := nNro
aPrefixo := aClone(aPARPre)
aTpGrafT := aClone(aPARTGT)
aTpGrafB := aClone(aPARTGB)
aTpGrafO := aClone(aPARTGO)
aTpGrafV := aClone(aPARTGV)
dDtIni := dPARDtI
dDtFin := dPARDtF
nNro   := nPARNro
aEmpr := aPAREmp
If !Empty(aPAREmp)
	cEmpr := " - "+STR0026+" "
	aEmpr := FS_FILIAIS() // Levantamento das Filiais
	If len(aEmpr) == 0
		MsgAlert(STR0027,STR0025)
		Return
	EndIf
Else
	aAdd(aEmpr,{ cFilAnt , aFWArrFilAtu[SM0_FILIAL] })
	If cUsuPerm # "*"
		aPrefixo := {}
		aTpGrafT := {}
		aAdd(aPrefixo,STR0002)
		aAdd(aTpGrafT,"")
		aTpGrafB := FS_PERM("BAL",aTpGrafB)
		If len(aTpGrafB) > 1
			aAdd(aPrefixo,STR0003)
		EndIf
		aTpGrafO := FS_PERM("OFI",aTpGrafO)
		If len(aTpGrafO) > 1
			aAdd(aPrefixo,STR0004)
		EndIf
		aTpGrafV := FS_PERM("VEI",aTpGrafV)
		If len(aTpGrafV) > 1
			aAdd(aPrefixo,STR0005)
		EndIf
	EndIf
EndIf
If len(aEmpr) == 1 .and. (aEmpr[1,1]==cFilAnt)
	cEmpr := " - "+Alltrim(FWFilialName())+" ( "+cFilAnt+" )"
EndIf

aInfo := { aSizeHalf[ 1 ] , aSizeHalf[ 2 ] , aSizeHalf[ 3 ] , aSizeHalf[ 4 ] , 3 , 3 } // Tamanho total da tela
aAdd( aObjects, { 0 ,  15 , .T. , .F. } ) // Parametros
aAdd( aObjects, { 0 , 100 , .T. , .T. } ) // Grafico
aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oGrafPOL FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE (STR0001+cEmpr) PIXEL OF oMainWnd
@ aPos[1,1]+004,003 SAY STR0031 SIZE 30,08 OF oGrafPOL PIXEL COLOR CLR_BLUE
@ aPos[1,1]+003,024 MSGET oDatIni VAR dDtIni VALID( dDtIni <= dDataBase ) SIZE 38,06 OF oGrafPOL PIXEL COLOR CLR_BLUE
@ aPos[1,1]+004,064 SAY STR0032 SIZE 10,08 OF oGrafPOL PIXEL COLOR CLR_BLUE
@ aPos[1,1]+003,069 MSGET oDatFin VAR dDtFin VALID( dDtIni <= dDtFin .and. dDtFin <= dDataBase ) SIZE 38,06 OF oGrafPOL PIXEL COLOR CLR_BLUE
@ aPos[1,1]+004,108 SAY STR0033 SIZE 30,06 OF oGrafPOL PIXEL COLOR CLR_BLUE
@ aPos[1,1]+003,129 MSCOMBOBOX oPrefixo VAR cPrefixo ITEMS aPrefixo VALID FS_PREFGRAF() SIZE 35,07 OF oGrafPOL PIXEL COLOR CLR_BLUE
@ aPos[1,1]+003,164 MSCOMBOBOX oTpGrafT VAR cTpGrafT ITEMS aTpGrafT VALID FS_GRAFICO(cTpGrafT) SIZE 180,07 OF oGrafPOL PIXEL COLOR CLR_BLUE
@ aPos[1,1]+003,164 MSCOMBOBOX oTpGrafB VAR cTpGrafB ITEMS aTpGrafB VALID FS_GRAFICO(cTpGrafB) SIZE 180,07 OF oGrafPOL PIXEL COLOR CLR_BLUE
@ aPos[1,1]+003,164 MSCOMBOBOX oTpGrafO VAR cTpGrafO ITEMS aTpGrafO VALID FS_GRAFICO(cTpGrafO) SIZE 180,07 OF oGrafPOL PIXEL COLOR CLR_BLUE
@ aPos[1,1]+003,164 MSCOMBOBOX oTpGrafV VAR cTpGrafV ITEMS aTpGrafV VALID FS_GRAFICO(cTpGrafV) SIZE 180,07 OF oGrafPOL PIXEL COLOR CLR_BLUE
@ aPos[1,1]+004,348 SAY STR0034 SIZE 35,08 OF oGrafPOL PIXEL COLOR CLR_BLUE
@ aPos[1,1]+003,378 MSGET oNro VAR nNro VALID (nNro>0,FS_GRAFICO()) SIZE 20,06 OF oGrafPOL PIXEL COLOR CLR_BLUE
oTPanGraf := TPanel():New(aPos[2,1] ,aPos[2,2],"",oGrafPOL,NIL,.T.,.F.,NIL,NIL,aPos[2,4]-aPos[2,2],aPos[2,3]-aPos[2,1],.T.,.F.)
@ aPos[1,1]+003,aPos[1,4]-050 BUTTON oEmpr PROMPT UPPER(STR0029) OF oGrafPOL SIZE 49,10 PIXEL ACTION (lEmpr:=.t.,oGrafPOL:End()) // Filiais

oTpGrafB:lVisible := .f.
oTpGrafO:lVisible := .f.
oTpGrafV:lVisible := .f.
ACTIVATE MSDIALOG oGrafPOL CENTER
If lEmpr
	OFIOC290(cEmpr,aEmpr,aPrefixo,aTpGrafT,aTpGrafB,aTpGrafO,aTpGrafV,dDtIni,dDtFin,nNro)
EndIf
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_PERM  ³ Autor ³  Andre Luis Almeida   ³ Data ³ 25/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Permissao do usuario                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PERM(cTp,aAux)
Local ni := 0
Local nj := 0
Local nx := 0
Local cPer := cUsuPerm
Local cAux := ""
Local nAux := 0
Local aRet := {}
aAdd(aRet,"")
For ni := 1 to len(cPer)
	cAux := left(cPer,5)
	nAux := len(Alltrim(cAux))
	If nAux == 0
		Exit
	EndIf
	If cTp $ cAux
		For nj := 1 to len(aAux)
			If left(aAux[nj],nAux) == left(cAux,nAux)
				nx := aScan(aRet, {|x| x == aAux[nj] })
				If nx == 0
					aAdd(aRet,aAux[nj])
					aAdd(aTpGrafT,aAux[nj])
				EndIf
			EndIf
		Next
	EndIf
	cPer := substr(cPer,7)
Next
Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_PREFGRAF³ Autor ³  Andre Luis Almeida  ³ Data ³ 25/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alterar lVisible dos tipos de grafico                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_PREFGRAF()
oTpGrafT:lVisible := .f.
oTpGrafB:lVisible := .f.
oTpGrafO:lVisible := .f.
oTpGrafV:lVisible := .f.
Do Case
	Case cPrefixo == STR0002
		oTpGrafT:lVisible := .t.
		oTpGrafT:SetFocus()
	Case cPrefixo == STR0003
		oTpGrafB:lVisible := .t.
		oTpGrafB:SetFocus()
	Case cPrefixo == STR0004
		oTpGrafO:lVisible := .t.
		oTpGrafO:SetFocus()
	Case cPrefixo == STR0005
		oTpGrafV:lVisible := .t.
		oTpGrafV:SetFocus()
EndCase
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_GRAFICO³ Autor ³  Andre Luis Almeida   ³ Data ³ 25/07/07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Montagem dos Graficos                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAFICO(cTpG)
Local aAux  := {}
Local cAux  := ""
Local nAux  := 0
Local nEmpr := 0
Local cTp   := ""
Local ni    := 0
Local nj    := 0
Local nPos  := 0
Default cTpG:= ""
If !Empty(cTpG)
	cTit  := ""
	nGraf := 4
	nx    := 1
	aGrafico := {}
	cTipGraf := cTpG
	cTp := left(cTipGraf,5)
EndIf
If !Empty(cTp)
	/////////////////////////////////////  BALCAO  //////////////////////////////////////
	If left(cTp,3) == "BAL"
		cTit := STR0003+" - "
		Do Case
			Case cTp == "BAL01"
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "B" , "1" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					cAux := ""
					For ni := 1 to len(aGrafico)
						If cAux # aGrafico[ni,1]
							cAux := aGrafico[ni,1]
							If aGrafico[ni,2] > 0
								nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],3) })
								If nPos == 0
									aadd(aAux,{left(aGrafico[ni,1],3),aGrafico[ni,2]})
								Else
									aAux[nPos,2] += aGrafico[ni,2]
								EndIf
							EndIf
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
			Case cTp == "BAL02"
				nx := 3
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "B" , "1" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 1 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],3) })
						If nPos == 0
							aadd(aAux,{left(aGrafico[ni,1],3),aGrafico[ni,2],aGrafico[ni,3],aGrafico[ni,4]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
							aAux[nPos,3] += aGrafico[ni,3]
							aAux[nPos,4] += aGrafico[ni,4]
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
			Case cTp == "BAL03"
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "B" , "1" , "2" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 1 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],3) })
						If nPos == 0
							aadd(aAux,{left(aGrafico[ni,1],3),aGrafico[ni,2]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
						EndIf
						nAux += aGrafico[ni,2]
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
				If len(aGrafico) > 12
					nGraf := 10
					For ni := 1 to len(aGrafico)
						aGrafico[ni,1] := aGrafico[ni,1]+Transform((aGrafico[ni,2]/nAux)*100,"@E 9999.9")+"%"
					Next
				EndIf
			Case cTp == "BAL04"
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "B" , "2" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					cAux := ""
					For ni := 1 to len(aGrafico)
						If cAux # aGrafico[ni,1]
							cAux := aGrafico[ni,1]
							If aGrafico[ni,2] > 0
								nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],6) })
								If nPos == 0
									aadd(aAux,{left(aGrafico[ni,1],6),aGrafico[ni,2]})
								Else
									aAux[nPos,2] += aGrafico[ni,2]
								EndIf
							EndIf
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
			Case cTp == "BAL05"
				nx := 3
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "B" , "2" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 1 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],6) })
						If nPos == 0
							aadd(aAux,{left(aGrafico[ni,1],6),aGrafico[ni,2],aGrafico[ni,3],aGrafico[ni,4]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
							aAux[nPos,3] += aGrafico[ni,3]
							aAux[nPos,4] += aGrafico[ni,4]
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
			Case cTp == "BAL06"
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "B" , "2" , "2" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 1 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],6) })
						If nPos == 0
							aadd(aAux,{left(aGrafico[ni,1],6),aGrafico[ni,2]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
						EndIf
						nAux += aGrafico[ni,2]
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
				If len(aGrafico) > 9
					nGraf := 10
					For ni := 1 to len(aGrafico)
						aGrafico[ni,1] := aGrafico[ni,1]+Transform((aGrafico[ni,2]/nAux)*100,"@E 999.9")+"%"
					Next
				EndIf
		EndCase
		/////////////////////////////////////  OFICINA  /////////////////////////////////////
	ElseIf left(cTp,3) == "OFI"
		cTit := STR0004+" - "
		Do Case
			Case cTp == "OFI01"
				nx := 2
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "O" , "1" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 2 to 3
						nPos := aScan(aAux, {|x| x[1] == aGrafico[ni,1] })
						If nPos == 0
							aadd(aAux,{aGrafico[ni,1],aGrafico[ni,2]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
						EndIf
					Next
				Next
				aGrafico := aclone(aAux)
			Case cTp == "OFI02"
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "O" , "1" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 4 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == aGrafico[ni,1] })
						If nPos == 0
							aadd(aAux,{aGrafico[ni,1],aGrafico[ni,2]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
			Case cTp == "OFI03"
				nx := 8
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "O" , "2" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 2 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == aGrafico[ni,1] })
						If nPos == 0
							aadd(aAux,{aGrafico[ni,1],aGrafico[ni,2],aGrafico[ni,3]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
							aAux[nPos,3] += aGrafico[ni,3]
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
			Case cTp == "OFI04"
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "O" , "3" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 1 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],2)+"/"+right(aGrafico[ni,1],4) })
						If nPos == 0
							aadd(aAux,{left(aGrafico[ni,1],2)+"/"+right(aGrafico[ni,1],4),aGrafico[ni,2]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
						EndIf
						nAux += aGrafico[ni,2]
					Next
				Next
				aGrafico := aclone(aAux)
				If len(aGrafico) > 12
					nGraf := 10
					For ni := 1 to len(aGrafico)
						aGrafico[ni,1] := aGrafico[ni,1]+Transform((aGrafico[ni,2]/nAux)*100,"@E 9999.9")+"%"
					Next
				EndIf
				aSort(aAux,1,,{|x,y| substr(x[1],4,4)+substr(x[1],1,2) < substr(y[1],4,4)+substr(y[1],1,2) })
			Case cTp == "OFI05"
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "O" , "3" , "2" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 1 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],2)+"/"+right(aGrafico[ni,1],4) })
						If nPos == 0
							aadd(aAux,{left(aGrafico[ni,1],2)+"/"+right(aGrafico[ni,1],4),aGrafico[ni,2]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
						EndIf
						nAux += aGrafico[ni,2]
					Next
				Next
				aGrafico := aclone(aAux)
				If len(aGrafico) > 12
					nGraf := 10
					For ni := 1 to len(aGrafico)
						aGrafico[ni,1] := aGrafico[ni,1]+Transform((aGrafico[ni,2]/nAux)*100,"@E 9999.9")+"%"
					Next
				EndIf
				aSort(aAux,1,,{|x,y| substr(x[1],4,4)+substr(x[1],1,2) < substr(y[1],4,4)+substr(y[1],1,2) })
		EndCase
		/////////////////////////////////////  VEICULO  /////////////////////////////////////
	Else // left(cTp,3) == "VEI"
		cTit := STR0005+" - "
		Do Case
			Case cTp == "VEI01"
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "V" , "1" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					cAux := ""
					For ni := 1 to len(aGrafico)
						If cAux # aGrafico[ni,1]
							cAux := aGrafico[ni,1]
							If aGrafico[ni,2] > 0
								nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],10) })
								If nPos == 0
									aadd(aAux,{left(aGrafico[ni,1],10),aGrafico[ni,2]})
								Else
									aAux[nPos,2] += aGrafico[ni,2]
								EndIf
							EndIf
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
			Case cTp == "VEI02"
				nx := 3
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "V" , "1" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 1 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],10) })
						If nPos == 0
							aadd(aAux,{left(aGrafico[ni,1],10),aGrafico[ni,2],aGrafico[ni,3],aGrafico[ni,4]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
							aAux[nPos,3] += aGrafico[ni,3]
							aAux[nPos,4] += aGrafico[ni,4]
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
			Case cTp == "VEI03"
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "V" , "1" , "2" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					cAux := ""
					For ni := 1 to len(aGrafico)
						If cAux # aGrafico[ni,1]
							cAux := aGrafico[ni,1]
							If aGrafico[ni,2] > 0
								nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],9) })
								If nPos == 0
									aadd(aAux,{left(aGrafico[ni,1],9),aGrafico[ni,2]})
								Else
									aAux[nPos,2] += aGrafico[ni,2]
								EndIf
								nAux += aGrafico[ni,2]
							EndIf
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
				If len(aGrafico) > 7
					nGraf := 10
					For ni := 1 to len(aGrafico)
						aGrafico[ni,1] := aGrafico[ni,1]+Transform((aGrafico[ni,2]/nAux)*100,"@E 999.9")+"%"
					Next
				EndIf
			Case cTp == "VEI04"
				nx := 3
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "V" , "1" , "2" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 1 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],10) })
						If nPos == 0
							aadd(aAux,{left(aGrafico[ni,1],10),aGrafico[ni,2],aGrafico[ni,3],aGrafico[ni,4]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
							aAux[nPos,3] += aGrafico[ni,3]
							aAux[nPos,4] += aGrafico[ni,4]
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
			Case cTp == "VEI05"
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "V" , "2" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					cAux := ""
					For ni := 1 to len(aGrafico)
						If cAux # aGrafico[ni,1]
							cAux := aGrafico[ni,1]
							If aGrafico[ni,2] > 0
								nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],6) })
								If nPos == 0
									aadd(aAux,{left(aGrafico[ni,1],6),aGrafico[ni,2]})
								Else
									aAux[nPos,2] += aGrafico[ni,2]
								EndIf
							EndIf
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
			Case cTp == "VEI06"
				nx := 3
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "V" , "2" , "1" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 1 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],6) })
						If nPos == 0
							aadd(aAux,{left(aGrafico[ni,1],6),aGrafico[ni,2],aGrafico[ni,3],aGrafico[ni,4]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
							aAux[nPos,3] += aGrafico[ni,3]
							aAux[nPos,4] += aGrafico[ni,4]
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
			Case cTp == "VEI07"
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "V" , "2" , "2" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					cAux := ""
					For ni := 1 to len(aGrafico)
						If cAux # aGrafico[ni,1]
							cAux := aGrafico[ni,1]
							If aGrafico[ni,2] > 0
								nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],6) })
								If nPos == 0
									aadd(aAux,{left(aGrafico[ni,1],6),aGrafico[ni,2]})
								Else
									aAux[nPos,2] += aGrafico[ni,2]
								EndIf
								nAux += aGrafico[ni,2]
							EndIf
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
				If len(aGrafico) > 9
					nGraf := 10
					For ni := 1 to len(aGrafico)
						aGrafico[ni,1] := aGrafico[ni,1]+Transform((aGrafico[ni,2]/nAux)*100,"@E 9999.9")+"%"
					Next
				EndIf
			Case cTp == "VEI08"
				nx := 3
				For nEmpr := 1 to len(aEmpr)
					aGrafico := OFIOC280( "V" , "2" , "2" , dDtIni , dDtFin , aEmpr[nEmpr,1] )
					For ni := 1 to len(aGrafico)
						nPos := aScan(aAux, {|x| x[1] == left(aGrafico[ni,1],6) })
						If nPos == 0
							aadd(aAux,{left(aGrafico[ni,1],6),aGrafico[ni,2],aGrafico[ni,3],aGrafico[ni,4]})
						Else
							aAux[nPos,2] += aGrafico[ni,2]
							aAux[nPos,3] += aGrafico[ni,3]
							aAux[nPos,4] += aGrafico[ni,4]
						EndIf
					Next
				Next
				aSort(aAux,1,,{|x,y| x[2] > y[2] })
				aGrafico := aclone(aAux)
		EndCase
	EndIf
	/////////////////////////////////////////////////////////////////////////////////////
EndIf
If len(aGrafico) > 0
	aAux := {}
	For ni := 1 to len(aGrafico)
		For nj := 2 to len(aGrafico[ni])
			aadd(aAux,{aGrafico[ni,nj],Alltrim(left(aGrafico[ni,1],15)),})
			If len(aAux) >= ( nNro * nx )
				Exit
			EndIf
		Next
		If len(aAux) >= ( nNro * nx )
			Exit
		EndIf
	Next
	If len(aAux) > 0
		If lPriVez
			FG_GRAFICO(oTPanGraf,cEmpr,15,2,,,aAux,nGraf,.f.)
			lPriVez := .f.
		EndIf
		FG_GRAFICO(oTPanGraf,cTit+cTipGraf+" ( "+STR0031+" "+Transform(dDtIni,"@D")+" "+STR0032+" "+Transform(dDtFin,"@D")+" ) - "+STR0035+str(nNro,4),15,2,,,aAux,nGraf,.f.)
	EndIf
Else
	If !Empty(cTpG)
		MsgAlert(STR0036,STR0025)
	EndIf
EndIf
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_FILIAIS³ Autor ³ Andre Luis Almeida       ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Levantamento das Filiais                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILIAIS()
Local aVetAux      := {}
Local ni           := {}
Local aFilAtu      := FWArrFilAtu()
Local aSM0         := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. )
Local cBkpFilAnt   := cFilAnt
Local nCont        := 0
Local aFWArrFilAtu := {}
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
For nCont := 1 to Len(aSM0)
	cFilAnt := aSM0[nCont]
	aFWArrFilAtu := FWArrFilAtu()
	ni := aScan(aEmpr,{|x| x[1] == cFilAnt })
	aAdd( aVetEmp, { (ni>0) , cFilAnt , aFWArrFilAtu[SM0_FILIAL] , FWFilialName() })
Next
cFilAnt := cBkpFilAnt
If Len(aVetEmp) > 1
	DEFINE MSDIALOG oDlgEmp FROM 05,01 TO 250,400 TITLE STR0029 PIXEL // Filiais
	@ 001,001 LISTBOX oLbEmp FIELDS HEADER "",STR0038,STR0039 COLSIZES 10,15,50 SIZE 165,120 OF oDlgEmp ON DBLCLICK (aVetEmp[oLbEmp:nAt,1]:=!aVetEmp[oLbEmp:nAt,1]) PIXEL
	oLbEmp:SetArray(aVetEmp)
	oLbEmp:bLine := { || {  IIf(aVetEmp[oLbEmp:nAt,1],oOk,oNo) ,;
	aVetEmp[oLbEmp:nAt,3],;
	aVetEmp[oLbEmp:nAt,4] }}
	DEFINE SBUTTON FROM 001,170 TYPE 1  ACTION (oDlgEmp:End()) ENABLE OF oDlgEmp
	@ 002, 002 CHECKBOX oMacTod VAR lMarcar PROMPT "" OF oDlgEmp ON CLICK IIf( FS_TIK(lMarcar ) , .t. , ( lMarcar:=!lMarcar , oDlgEmp:Refresh() ) ) 	SIZE 70,08 PIXEL COLOR CLR_BLUE
	ACTIVATE MSDIALOG oDlgEmp CENTER
EndIf
If len(aVetEmp) == 1
	aVetEmp[1,1] := .t.
EndIf
For ni := 1 to len(aVetEmp)
	If aVetEmp[ni,1]
		aAdd( aVetAux, { aVetEmp[ni,2] , aVetEmp[ni,3] })
		cEmpr += Alltrim(aVetEmp[ni,2])+", "
	EndIf
Next
If len(aVetAux) > 1
	cEmpr := substr(cEmpr,1,len(cEmpr)-2)
EndIf
Return(aVetAux)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao   ³ FS_TIK    ³ Autor ³ Andre Luis Almeida       ³ Data ³ 20/05/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao³ Tik Total das Filiais                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TIK(lMarcar)
Local ni := 0
Default lMarcar := .f.
For ni := 1 to Len(aVetEmp)
	If lMarcar
		aVetEmp[ni,1] := .t.
	Else
		aVetEmp[ni,1] := .f.
	EndIf
Next
oLbEmp:SetFocus()
oLbEmp:Refresh()
Return(.t.)