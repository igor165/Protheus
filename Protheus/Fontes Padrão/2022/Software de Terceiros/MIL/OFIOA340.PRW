// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 03     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼  
#Include "OFIOA340.ch"
#Include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOA340 ³ Autor ³  Andre Luis Almeida   ³ Data ³ 27/08/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verbas: Cadastro de Clientes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOA340               
	Local aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
	Private cFilSM0 := ( aSM0[2] +" - "+ Alltrim(aSM0[6]) +" "+ Alltrim(aSM0[5]) )
	Private aClientes := {{" "," "," "}}
	Private cClientes := ""
	Private cCodCli   := space(6)
	Private cLojCli   := space(2)
	Private lAltera := .f.
	DbSelectArea("VAI") 	
	DbSetOrder(4)
	If DbSeek( xFilial("VAI") + __CUSERID )
		If strzero(VAI->VAI_NVERBA,1) == "3"
			lAltera := .t.
		EndIf
	EndIf
	FS_LISCLI("INICIAL")
   DEFINE MSDIALOG oVerba FROM 000,000 TO 021,058 TITLE (STR0001+cFilSM0) OF oMainWnd
   @ 012,008 SAY STR0002 SIZE 40,08 OF oVerba PIXEL COLOR CLR_BLUE
   @ 011,027 MSGET  oCodCli VAR cCodCli  PICTURE "!!!!!!" VALID FS_VALCLI(cCodCli) SIZE 20,08 F3 "SA1" OF oVerba PIXEL COLOR CLR_HBLUE WHEN lAltera
   @ 011,057 MSGET  oLojCli VAR cLojCli  PICTURE "!!" VALID FS_VALCLI(cCodCli+cLojCli) SIZE 01,08 OF oVerba PIXEL COLOR CLR_HBLUE WHEN lAltera
   @ 011,072 BUTTON oCadCli PROMPT OemToAnsi(STR0003) OF oVerba SIZE 48,10 PIXEL  ACTION (FS_CADCLI(),oCodCli:SetFocus()) WHEN lAltera
   @ 030,003 LISTBOX oLbx1 FIELDS HEADER OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008) COLSIZES 27,50,123 SIZE 225,125 OF oVerba PIXEL
   oLbx1:SetArray(aClientes)
   oLbx1:bLine := { || {aClientes[oLbx1:nAt,1],;
                        aClientes[oLbx1:nAt,2],;
                        aClientes[oLbx1:nAt,3]}}
   @ 003,003 TO 027,228 LABEL "" OF oVerba PIXEL 
   @ 011,123 BUTTON oExcCli PROMPT OemToAnsi(STR0004) OF oVerba SIZE 48,10 PIXEL  ACTION (FS_EXCCLI(oLbx1:nAt)) WHEN lAltera
   @ 011,175 BUTTON oSair PROMPT OemToAnsi(STR0005) OF oVerba SIZE 48,10 PIXEL ACTION (oVerba:End())
   ACTIVATE MSDIALOG oVerba CENTER 
Return

Static Function FS_LISCLI(cTip)
	Local ni := 0
	aClientes := {}
	cClientes := Alltrim(GetMV("MV_CTRLVER"))
	For ni := 1 to len(cClientes)
		DbSelectArea("SA1")
		DbSetOrder(1)
		If DbSeek( xFilial("SA1") + left(cClientes,8) )
			aAdd(aClientes,{SA1->A1_COD+"-"+SA1->A1_LOJA," "+Transform(SA1->A1_CGC,If(Len(Alltrim(SA1->A1_CGC))>12,"@R 99.999.999/9999-99","@R 999.999.999-99"))+" ", " "+left(SA1->A1_NOME+space(35),35)} )
      EndIf
      cClientes := Alltrim(substr(cClientes,10))
      If Empty(cClientes)
      	Exit
      EndIf
	Next
	If len(aClientes) == 0
		aClientes := {{" "," "," "}}
	Else
		aSort(aClientes,1,,{|x,y| x[3] < y[3] })
	EndIf
	If cTip # "INICIAL"
	   oLbx1:SetArray(aClientes)
   	oLbx1:bLine := { || {aClientes[oLbx1:nAt,1],;
      	              	   aClientes[oLbx1:nAt,2],;
         	           	 	aClientes[oLbx1:nAt,3]}}
		oLbx1:Refresh()
	EndIf
Return()

Static Function FS_CADCLI()
	Local ni   := 0
	Local lRet := .f.
	Local aCli := {}
	If !Empty(Alltrim(cCodCli+cLojCli))
		If FS_VALCLI(cCodCli+cLojCli)
			For ni := 1 to len(aClientes)
				If !Empty(Alltrim(left(aClientes[ni,1],6)))
					aAdd(aCli,{aClientes[ni,1],ni} )
				EndIf
			Next
			aAdd(aCli,{cCodCli+"-"+cLojCli,ni++} )
			aSort(aCli,1,,{|x,y| x[1] < y[1] })
			cClientes := ""
			For ni := 1 to len(aCli)
				cClientes += substr(aCli[ni,1],1,6)+substr(aCli[ni,1],8,2)+"/"
			Next
			lRet := .t.
			If SX6->(DbSeek(xFilial("SX6")+"MV_CTRLVER"))
				RecLock("SX6",.f.)
					SX6->X6_CONTEUD := cClientes
					SX6->X6_CONTSPA := cClientes
					SX6->X6_CONTENG := cClientes
				MsUnlock()
				FS_LISCLI()
			EndIf
		EndIf
		cCodCli := space(6)
		cLojCli := space(2)
	EndIf
Return(lRet)

Static Function FS_EXCCLI(nPos)
	Local ni   := 0
	Local lRet := .f.
	Local aAux := {}
	cClientes  := ""
	If !Empty(aClientes[nPos,1])
		For ni := 1 to len(aClientes)
			If ni # nPos
				aAdd(aAux,{aClientes[ni,1],aClientes[ni,2],aClientes[ni,3]})
			EndIf
		Next
		aClientes := aClone(aAux)
		aSort(aAux,1,,{|x,y| x[1] < y[1] })
		For ni := 1 to len(aAux)
			cClientes += substr(aAux[ni,1],1,6)+substr(aAux[ni,1],8,2)+"/"
		Next
		If SX6->(DbSeek(xFilial("SX6")+"MV_CTRLVER"))
			RecLock("SX6",.f.)
				SX6->X6_CONTEUD := cClientes
				SX6->X6_CONTSPA := cClientes
				SX6->X6_CONTENG := cClientes
			MsUnlock()
			FS_LISCLI()
		EndIf
	EndIf
Return(lRet)

Static Function FS_VALCLI(cSeek)
	Local lRet := .f.
	cClientes := Alltrim(GetMV("MV_CTRLVER"))
	If Empty(Alltrim(cCodCli+cLojCli))
		lRet := .t.
	Else
		If ( cCodCli+cLojCli $ cClientes )
			MsgAlert(STR0010,STR0009)
		Else
			DbSelectArea("SA1")
			DbSetOrder(1)
			If DbSeek( xFilial("SA1") + cSeek )
				cLojCli := SA1->A1_LOJA
				lRet := .t.
			EndIf
		EndIf
	EndIf
Return(lRet)
